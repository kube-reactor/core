#!/usr/bin/env python3
#
# Usage:
#
#  generate_template.py <template_name> <project dir> <template dir>
#
#    : Output status messages
#    : Return nothing
#
# =========================================================================================
# Initialization
#
import os
import sys
import pathlib
import shutil
import shlex
import errno
import re
import json
import ruamel.yaml

yaml = ruamel.yaml.YAML()
yaml.preserve_quotes = True
yaml.preserve_comments = True
yaml.default_flow_style = False

template_name = sys.argv[1]
project_dir = sys.argv[2]
template_dir = sys.argv[3]

cookiecutter_dir = os.path.join(template_dir, "{{cookiecutter.__project_key}}")
cookiecutter_file = os.path.join(template_dir, "cookiecutter.json")
reactor_file = "reactor.yml"
access_file = "access.yml"
env_dir = "env"
static_files = ["argocd", "projects", "reactor", ".gitignore", "LICENSE"]


def cookiecutter_token(variable):
    return "{{cookiecutter." + variable + "}}"


def load_file(file_path):
    with open(file_path, "r") as file:
        return file.read()


def load_yaml_file(file_path):
    with open(file_path, "r") as file:
        return yaml.load(file)


def load_json_file(file_path):
    with open(file_path, "r") as file:
        return json.loads(file)


def ensure_parent_directories(file_path):
    directory = os.path.dirname(file_path)
    if directory:
        os.makedirs(directory, exist_ok=True)


def save_file(file_path, content):
    ensure_parent_directories(file_path)
    with open(file_path, "w") as file:
        file.write(content)


def save_yaml_file(file_path, yaml_data):
    ensure_parent_directories(file_path)
    with open(file_path, "w") as file:
        yaml.dump(yaml_data, file)


def save_json_file(file_path, json_data):
    ensure_parent_directories(file_path)
    with open(file_path, "w") as file:
        file.write(json.dumps(json_data, indent=2))


def remove_path(file_path):
    if os.path.exists(file_path):
        if os.path.isdir(file_path):
            shutil.rmtree(file_path)
        else:
            pathlib.Path(file_path).unlink()


def copy_path(source_path, dest_path):
    try:
        shutil.copytree(source_path, dest_path)
    except OSError as error:
        if error.errno in (errno.ENOTDIR, errno.EINVAL):
            shutil.copy(source_path, dest_path)
        else:
            raise error


def parse_value_to_python_type(value_str):
    """
    Attempts to convert a string value to an integer, float, or returns it as a string.
    """
    # Try int
    try:
        return int(value_str)
    except ValueError:
        pass
    # Try float
    try:
        return float(value_str)
    except ValueError:
        pass
    # Try bool
    try:
        if value_str in ["true", "TRUE", "True", "false", "FALSE", "False"]:
            return True if value_str in ["true", "TRUE", "True"] else False
    except ValueError:
        pass
    # Default to string
    return value_str


def parse_exported_variables(script_content):
    exported_vars = {}
    lines = script_content.splitlines()
    num_lines = len(lines)

    line_idx = 0
    while line_idx < num_lines:
        original_line_text = lines[line_idx]
        stripped_line_for_check = original_line_text.lstrip()

        if not stripped_line_for_check.startswith("export "):
            line_idx += 1
            continue

        # --- PRE-CHECK FOR TEMPLATE COMMENTS AND [required] TOKEN ---
        help_message_lines = []
        raw_template_comment_lines = []  # Store full comment lines for [required] check
        found_template_prefix = False
        template_category = None
        is_environment_specific = False

        template_prefix_pattern = r"^\#\s*\[template(?:\:([^\]]+))\]\:\s*(.+)$"
        template_env_prefix_pattern = r"^\#\s*\[template.env(?:\:([^\]]+))\]\:\s*(.+)$"

        # Iterate backwards from the line immediately preceding the export.
        for k_help_idx in range(line_idx - 1, -1, -1):
            prev_line_content = lines[k_help_idx]
            prev_line_stripped = prev_line_content.strip()

            template_matches = re.search(template_prefix_pattern, prev_line_stripped)
            if not template_matches:
                template_env_matches = re.search(
                    template_env_prefix_pattern, prev_line_stripped
                )

            if template_matches:
                found_template_prefix = True
                template_category = template_matches.group(1)
                help_message_lines.insert(0, template_matches.group(2).lstrip())
                raw_template_comment_lines.insert(0, prev_line_content)

            elif template_env_matches:
                found_template_prefix = True
                template_category = template_env_matches.group(1)
                help_message_lines.insert(0, template_env_matches.group(2).lstrip())
                raw_template_comment_lines.insert(0, prev_line_content)
            elif (
                prev_line_stripped.startswith("#") or not prev_line_stripped
            ):  # Empty or other comment
                # This breaks the contiguity of #[template]: blocks
                break
            else:  # Non-comment, non-empty line
                break

        # If no #[template]: comment was found, skip this export statement entirely
        if not found_template_prefix:
            line_idx += 1  # Advance past the current "export" line
            continue  # Skip to the next line in the script

        # If we are here, `found_template_prefix` is True.
        # Now, check for "[required]" in the collected template comment lines
        for comment_text in raw_template_comment_lines:
            if "[template.env]" in comment_text or "[template.env:" in comment_text:
                is_environment_specific = True
                break

        help_message = "\n".join(help_message_lines)

        # --- PROCEED WITH PARSING THE EXPORT STATEMENT ---
        declaration_part = stripped_line_for_check[len("export ") :].lstrip()
        var_name_match = re.match(r"([a-zA-Z_][a-zA-Z0-9_]*)", declaration_part)

        if not var_name_match:
            line_idx += 1
            continue

        var_name = var_name_match.group(1)
        after_var_name_in_declaration = declaration_part[len(var_name) :].lstrip()

        statement_last_line_idx = line_idx  # Default for single-line

        value_start_candidate = after_var_name_in_declaration
        if value_start_candidate.startswith("="):
            value_start_candidate = value_start_candidate[1:].lstrip()

        # (Multi-line parsing logic for full_match - same as before)
        if value_start_candidate.startswith("("):  # Array
            paren_level = 0
            idx_of_opening_paren_in_decl_part = -1
            scan_area_for_paren = declaration_part[len(var_name) :]
            paren_char_actual_pos_in_scan_area = scan_area_for_paren.find("(")
            if paren_char_actual_pos_in_scan_area != -1:
                idx_of_opening_paren_in_decl_part = (
                    len(var_name) + paren_char_actual_pos_in_scan_area
                )

            if idx_of_opening_paren_in_decl_part != -1:
                for k_scan_line_idx in range(line_idx, num_lines):
                    current_scan_line_content = lines[k_scan_line_idx]
                    iter_char_start_idx = 0
                    if k_scan_line_idx == line_idx:
                        offset_of_decl_part_in_orig_line = original_line_text.find(
                            declaration_part
                        )
                        if offset_of_decl_part_in_orig_line != -1:
                            iter_char_start_idx = (
                                offset_of_decl_part_in_orig_line
                                + idx_of_opening_paren_in_decl_part
                            )
                        else:
                            statement_last_line_idx = k_scan_line_idx
                            break

                    in_s_quote, in_d_quote, escaped = False, False, False
                    for char_idx, char_val in enumerate(current_scan_line_content):
                        if (
                            k_scan_line_idx == line_idx
                            and char_idx < iter_char_start_idx
                        ):
                            continue
                        if escaped:
                            escaped = False
                            continue
                        if char_val == "\\":
                            escaped = True
                            continue
                        if char_val == "'" and not in_d_quote:
                            in_s_quote = not in_s_quote
                        elif char_val == '"' and not in_s_quote:
                            in_d_quote = not in_d_quote
                        if in_s_quote or in_d_quote:
                            continue
                        if char_val == "(":
                            paren_level += 1
                        elif char_val == ")":
                            paren_level -= 1

                    statement_last_line_idx = k_scan_line_idx
                    if paren_level == 0:
                        break
                    if k_scan_line_idx == num_lines - 1:
                        break

        elif value_start_candidate.startswith('"') or value_start_candidate.startswith(
            "'"
        ):  # Quoted String
            quote_char = value_start_candidate[0]
            in_target_string = False
            idx_of_opening_quote_in_decl_part = -1
            scan_area_for_quote = declaration_part[len(var_name) :]
            quote_char_actual_pos_in_scan_area = scan_area_for_quote.find(quote_char)
            if quote_char_actual_pos_in_scan_area != -1:
                idx_of_opening_quote_in_decl_part = (
                    len(var_name) + quote_char_actual_pos_in_scan_area
                )

            if idx_of_opening_quote_in_decl_part != -1:
                for k_scan_line_idx in range(line_idx, num_lines):
                    current_scan_line_content = lines[k_scan_line_idx]
                    iter_char_start_idx = 0
                    if k_scan_line_idx == line_idx:
                        offset_of_decl_part_in_orig_line = original_line_text.find(
                            declaration_part
                        )
                        if offset_of_decl_part_in_orig_line != -1:
                            iter_char_start_idx = (
                                offset_of_decl_part_in_orig_line
                                + idx_of_opening_quote_in_decl_part
                            )
                            in_target_string = True
                        else:
                            statement_last_line_idx = k_scan_line_idx
                            break

                    if not in_target_string and k_scan_line_idx > line_idx:
                        in_target_string = True
                    string_closed_on_this_line = False
                    if in_target_string:
                        escaped = False
                        char_scan_offset = (
                            (iter_char_start_idx + 1)
                            if k_scan_line_idx == line_idx
                            else 0
                        )
                        for char_val in current_scan_line_content[char_scan_offset:]:
                            if escaped:
                                escaped = False
                                continue
                            if char_val == "\\":
                                escaped = True
                                continue
                            if char_val == quote_char:
                                in_target_string = False
                                string_closed_on_this_line = True
                                break
                    statement_last_line_idx = k_scan_line_idx
                    if not in_target_string and string_closed_on_this_line:
                        break
                    if k_scan_line_idx == num_lines - 1:
                        break
        # End of multi-line full_match logic.

        full_match = "\n".join(lines[line_idx : statement_last_line_idx + 1])

        # --- PARSE DEFAULT VALUE ---
        parsed_default_value = None
        val_str_to_parse = None

        # Regex to find var_name, optional '=', and then capture the rest as the value string
        # This search is done on the potentially multi-line `full_match`
        match_var_then_value = re.search(
            re.escape(var_name) + r"\s*(?:=\s*)?(.*)",
            full_match,
            re.DOTALL,  # Allow . to match newline characters
        )

        candidate_val_str = None
        if match_var_then_value:
            # Group 1 is everything after "VAR_NAME" and optional " = "
            candidate_val_str = match_var_then_value.group(1).strip()

        if candidate_val_str:  # Only proceed if there's a non-empty value string
            val_str_to_parse = candidate_val_str

        if val_str_to_parse:
            if val_str_to_parse.startswith("(") and val_str_to_parse.endswith(")"):
                array_content = val_str_to_parse[1:-1].strip()
                try:
                    parsed_elements = shlex.split(array_content)
                    parsed_default_value = [
                        parse_value_to_python_type(item) for item in parsed_elements
                    ]
                except ValueError:
                    parsed_default_value = val_str_to_parse  # Fallback: malformed array
            elif (
                val_str_to_parse.startswith('"') and val_str_to_parse.endswith('"')
            ) or (val_str_to_parse.startswith("'") and val_str_to_parse.endswith("'")):
                try:
                    unquoted_value_str = shlex.split(val_str_to_parse)[0]
                except IndexError:  # Handles "" or ''
                    unquoted_value_str = ""
                except ValueError:  # shlex parsing error
                    unquoted_value_str = val_str_to_parse[1:-1]  # Fallback
                parsed_default_value = parse_value_to_python_type(unquoted_value_str)
            else:  # Unquoted value
                parsed_default_value = parse_value_to_python_type(val_str_to_parse)

        exported_vars[var_name] = {
            "full_match": full_match,
            "help_message": help_message,
            "default": parsed_default_value,
            "environment": is_environment_specific,
            "category": template_category,
        }

        line_idx = statement_last_line_idx + 1  # Advance main loop

    return exported_vars


def sort_variables(variable_data):
    sort_keys = ["category"]
    return dict(
        sorted(
            variable_data.items(), key=lambda item: [item[1][key] for key in sort_keys]
        )
    )


def migrate_access():
    project_file = os.path.join(project_dir, access_file)
    template_file = os.path.join(cookiecutter_dir, access_file)
    access_data = load_yaml_file(project_file)

    for function, types in access_data.items():
        for type, emails in types.items():
            types[type] = []

    save_yaml_file(template_file, access_data)


def migrate_files():
    for static_file in static_files:
        project_file = os.path.join(project_dir, static_file)
        template_file = os.path.join(cookiecutter_dir, static_file)

        remove_path(template_file)
        copy_path(project_file, template_file)


def update_cookiecutter():

    def update_meta_info():
        project_file = os.path.join(project_dir, reactor_file)
        template_file = os.path.join(cookiecutter_dir, reactor_file)
        reactor_info = load_yaml_file(project_file)
        template_variables = {}

        template_variables["__project_key"] = {
            "default": template_name,
            "help_message": "Project short name (lowercase alphanumeric and underscores only)",
        }
        reactor_info["short_name"] = cookiecutter_token("__project_key")

        template_variables["project_name"] = {
            "default": reactor_info["name"],
            "help_message": "Cluster project human readable name",
        }
        reactor_info["name"] = cookiecutter_token("project_name")

        for environment, domain in reactor_info.get("domain", {}).items():
            variable = f"{environment}_domain"
            template_variables[variable] = {
                "default": reactor_info["domain"][environment],
                "help_message": f"Project {environment} environment domain",
            }
            reactor_info["domain"][environment] = cookiecutter_token(variable)

        template_variables["open_source_license"] = {
            "default": ["apache2", "none"],
            "help_message": {
                "__prompt__": "Include open source license?",
                "apache2": "Apache Software License 2.0",
                "none": "Not open source",
            },
        }

        template_variables["include_circleci"] = {
            "default": True,
            "help_message": "Include basic CircleCI continuous integration configuration (if it doesn't exist yet)",
        }

        save_yaml_file(template_file, reactor_info)
        return template_variables

    def update_env_variables():
        project_env_dir = os.path.join(project_dir, env_dir)
        template_env_dir = os.path.join(cookiecutter_dir, env_dir)
        template_variables = {}

        environments = os.listdir(project_env_dir)

        if "prod" in environments:
            environments.remove("prod")
            environments = ["prod"] + environments
        if "production" in environments:
            environments.remove("production")
            environments = ["production"] + environments

        if "local" in environments:
            environments.remove("local")
            environments = environments + ["local"]

        for environment in environments:
            sub_env_file = os.path.join(project_env_dir, environment)

            if os.path.isdir(sub_env_file):
                public_env_file = "public.sh"
                project_public_env = os.path.join(sub_env_file, public_env_file)
                if os.path.isfile(project_public_env):
                    template_public_env = os.path.join(
                        template_env_dir, environment, public_env_file
                    )
                    public_env_script = load_file(project_public_env)

                    for env_var, variable_info in parse_exported_variables(
                        public_env_script
                    ).items():
                        if variable_info["environment"]:
                            variable_name = f"{environment}_{env_var}".lower()
                        else:
                            variable_name = env_var.lower()

                        variable_info["file"] = project_public_env
                        template_variables[variable_name] = variable_info

                        public_env_script = public_env_script.replace(
                            variable_info["full_match"],
                            f'export {env_var}="'
                            + cookiecutter_token(variable_name)
                            + '"',
                        )

                    save_file(template_public_env, public_env_script)

                secret_env_file = "secret.example.sh"
                project_secret_env = os.path.join(sub_env_file, secret_env_file)
                if os.path.isfile(project_secret_env):
                    template_secret_env = os.path.join(
                        template_env_dir, environment, secret_env_file
                    )
                    secret_env_script = load_file(project_secret_env)

                    for env_var, variable_info in parse_exported_variables(
                        secret_env_script
                    ).items():
                        if variable_info["environment"]:
                            variable_name = f"{environment}_{env_var}".lower()
                        else:
                            variable_name = env_var.lower()

                        variable_info["file"] = project_secret_env
                        template_variables[variable_name] = variable_info

                        secret_env_script = secret_env_script.replace(
                            variable_info["full_match"],
                            f'export {env_var}="'
                            + cookiecutter_token(variable_name)
                            + '"',
                        )

                    save_file(template_secret_env, secret_env_script)
            else:
                template_env_file = os.path.join(template_env_dir, environment)
                env_library_script = load_file(sub_env_file)

                for env_var, variable_info in parse_exported_variables(
                    env_library_script
                ).items():
                    if variable_info["environment"]:
                        variable_name = (
                            f"{os.path.splitext(environment)[0]}_{env_var}".lower()
                        )
                    else:
                        variable_name = env_var.lower()

                    variable_info["file"] = sub_env_file
                    template_variables[variable_name] = variable_info

                    env_library_script = env_library_script.replace(
                        variable_info["full_match"],
                        f'export {env_var}="' + cookiecutter_token(variable_name) + '"',
                    )

                save_file(template_env_file, env_library_script)

        return template_variables

    def update_index(meta_info, env_variables):
        cookiecutter_variables = {}
        cookiecutter_prompts = {}

        for variable_name, variable_info in meta_info.items():
            cookiecutter_variables[variable_name] = variable_info["default"]
            if variable_info["help_message"]:
                cookiecutter_prompts[variable_name] = variable_info["help_message"]

        for variable_name, variable_info in sort_variables(env_variables).items():
            cookiecutter_variables[variable_name] = variable_info["default"]
            if variable_info["help_message"]:
                cookiecutter_prompts[variable_name] = variable_info["help_message"]

        cookiecutter_variables["__prompts__"] = cookiecutter_prompts
        cookiecutter_variables["_copy_without_render"] = static_files

        save_json_file(cookiecutter_file, cookiecutter_variables)
        return cookiecutter_variables

    def ensure_project_files(cookiecutter_data):
        project_files = ["hooks", ".gitignore", "README.md"]
        if cookiecutter_data["include_circleci"]:
            project_files.append(".circleci")

        for project_file in project_files:
            project_path = os.path.join(
                os.environ["__utilities_dir"], "template", project_file
            )
            template_path = os.path.join(template_dir, project_file)

            if os.path.exists(project_path) and not os.path.exists(template_path):
                copy_path(project_path, template_path)

    cookiecutter_data = update_index(update_meta_info(), update_env_variables())
    ensure_project_files(cookiecutter_data)


migrate_access()
migrate_files()
update_cookiecutter()
