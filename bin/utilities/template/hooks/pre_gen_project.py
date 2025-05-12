"""
NOTE:
    The below Cookiecutter hook maintains a Reactor based CookieCutter project initialization

    * It validates Cookiecutter input and makes any updates to variables needed
"""

TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "

# The content of this string is evaluated by Jinja, and plays an important role.
# It updates the cookiecutter context to trim leading and trailing spaces
# from values
"""
{% for variable, value in cookiecutter.items() %}
  {% if value is string %}
    {{ cookiecutter.update({ variable: value | trim }) }}
  {% endif %}
{% endfor %}
"""

project_slug = "{{ cookiecutter.project_slug }}"
if hasattr(project_slug, "isidentifier"):
    assert (
        project_slug.isidentifier()
    ), "'{}' project slug is not a valid Python identifier.".format(project_slug)

assert (
    project_slug == project_slug.lower()
), "'{}' project slug should be all lowercase".format(project_slug)
