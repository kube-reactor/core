Search.setIndex({"docnames": ["advanced_usage/cicd_automation", "advanced_usage/performance_tuning", "advanced_usage/production_setup", "advanced_usage/readme", "advanced_usage/scaling_kubernetes", "changelog/readme", "cli_command_reference/best_practices", "cli_command_reference/command_list", "cli_command_reference/command_syntax", "cli_command_reference/readme", "cli_command_reference/usage_patterns", "community_support/contributing", "community_support/filing_issues", "community_support/paid_support", "community_support/readme", "community_support/support_links", "configuration_guide/argocd_configuration", "configuration_guide/core_configuration", "configuration_guide/kubernetes_configuration", "configuration_guide/readme", "configuration_guide/terraform_configuration", "configuration_guide/troubleshooting", "core_concepts/cli_structure", "core_concepts/key_terminology", "core_concepts/kubernetes_integration", "core_concepts/modularity", "core_concepts/project_structure", "core_concepts/readme", "faq/readme", "getting_started/basic_concepts", "getting_started/installation", "getting_started/quick_start", "getting_started/readme", "getting_started/simple_example", "getting_started/system_requirements", "modular_architecture/extensions", "modular_architecture/guiding_principles", "modular_architecture/hooks", "modular_architecture/readme", "modular_architecture/templates", "readme", "testing/readme", "testing/test_architecture", "testing/testing_core", "testing/testing_extensions", "testing/testing_projects", "troubleshooting/common_issues_solutions", "troubleshooting/connectivity_issues", "troubleshooting/logging_debugging", "troubleshooting/performance_troubleshooting", "troubleshooting/readme", "troubleshooting/resource_usage_monitoring"], "filenames": ["advanced_usage/cicd_automation.rst", "advanced_usage/performance_tuning.rst", "advanced_usage/production_setup.rst", "advanced_usage/readme.rst", "advanced_usage/scaling_kubernetes.rst", "changelog/readme.rst", "cli_command_reference/best_practices.rst", "cli_command_reference/command_list.rst", "cli_command_reference/command_syntax.rst", "cli_command_reference/readme.rst", "cli_command_reference/usage_patterns.rst", "community_support/contributing.rst", "community_support/filing_issues.rst", "community_support/paid_support.rst", "community_support/readme.rst", "community_support/support_links.rst", "configuration_guide/argocd_configuration.rst", "configuration_guide/core_configuration.rst", "configuration_guide/kubernetes_configuration.rst", "configuration_guide/readme.rst", "configuration_guide/terraform_configuration.rst", "configuration_guide/troubleshooting.rst", "core_concepts/cli_structure.rst", "core_concepts/key_terminology.rst", "core_concepts/kubernetes_integration.rst", "core_concepts/modularity.rst", "core_concepts/project_structure.rst", "core_concepts/readme.rst", "faq/readme.rst", "getting_started/basic_concepts.rst", "getting_started/installation.rst", "getting_started/quick_start.rst", "getting_started/readme.rst", "getting_started/simple_example.rst", "getting_started/system_requirements.rst", "modular_architecture/extensions.rst", "modular_architecture/guiding_principles.rst", "modular_architecture/hooks.rst", "modular_architecture/readme.rst", "modular_architecture/templates.rst", "readme.rst", "testing/readme.rst", "testing/test_architecture.rst", "testing/testing_core.rst", "testing/testing_extensions.rst", "testing/testing_projects.rst", "troubleshooting/common_issues_solutions.rst", "troubleshooting/connectivity_issues.rst", "troubleshooting/logging_debugging.rst", "troubleshooting/performance_troubleshooting.rst", "troubleshooting/readme.rst", "troubleshooting/resource_usage_monitoring.rst"], "titles": ["CI/CD and Automation", "Performance Tuning", "Production Setup", "Reactor Advanced Usage", "Scaling Kubernetes Clusters", "Release Notes and Changelog", "Best Practices", "Command List", "Command Syntax", "Reactor CLI Command Reference", "Usage Patterns", "Contributing", "Filing Issues", "Paid Support", "Community and Support", "Support Links", "ArgoCD Configuration", "Core Configuration", "Kubernetes Configuration", "Reactor Configuration Guide", "Terraform Configuration", "Configuration Troubleshooting", "CLI Structure", "Key Terminology", "Kubernetes Integration", "Modularity and Extensibility", "Project Structure", "Reactor Core Concepts", "Frequently Asked Questions", "Basic Concepts", "Installation", "Quick Start Guide", "Getting Started with Reactor", "A Simple Example", "System Requirements", "Extensions", "Guiding Principles", "Hooks", "Reactor Modular Architecture", "Templates", "Reactor System Documentation", "Reactor Testing", "Reactor Test Architecture", "Reactor Core Testing", "Reactor Extension Testing", "Reactor Project Testing", "Common Issues and Solutions", "Connectivity Issues", "Logging and Debugging", "Performance Troubleshooting", "Reactor Troubleshooting", "Resource Usage Monitoring"], "terms": {"The": [3, 9, 14, 19, 27, 34, 38, 41, 50], "section": [3, 9, 14, 19, 27, 30, 32, 38, 41, 50], "i": [3, 9, 19, 30, 32, 34, 38, 41], "design": [3, 27, 38, 40], "user": [3, 9, 14, 30, 38, 40], "who": [3, 9, 30], "ar": [3, 27, 34, 41], "readi": [3, 32, 40, 41], "take": 3, "experi": [3, 14, 32], "next": [3, 32], "level": [3, 41], "thi": [3, 9, 14, 19, 27, 30, 32, 34, 38, 41, 50], "cover": [3, 41], "topic": [3, 40], "go": 3, "beyond": [3, 14], "basic": [3, 32, 40], "help": [3, 9, 14, 19, 30, 32, 41, 50], "you": [3, 9, 14, 19, 27, 30, 32, 38, 41, 50], "optim": [3, 9, 19, 50], "your": [3, 14, 19, 27, 30, 32, 34, 38, 40, 41, 50], "kubernet": [3, 9, 19, 27, 30, 32, 34, 38, 40, 41, 50], "deploy": [3, 19, 38, 40, 41, 50], "product": [3, 9, 40, 41], "environ": [3, 9, 19, 27, 30, 32, 34, 38, 40, 41, 50], "In": [3, 9, 14, 19, 32, 41], "setup": [3, 19, 30, 34, 40], "subsect": [3, 9, 14, 19, 27, 38, 41, 50], "ll": [3, 9, 14, 19, 27, 32, 38, 40, 41, 50], "learn": [3, 14, 19], "best": [3, 9, 27, 40, 41, 50], "practic": [3, 9, 27, 40, 41, 50], "configur": [3, 30, 32, 34, 38, 40], "reliabl": [3, 41], "scalabl": [3, 27, 38, 40], "secur": [3, 34], "oper": [3, 9, 19, 32, 40, 41, 50], "context": 3, "For": [3, 14, 30, 50], "look": [3, 14, 40], "implement": 3, "continu": [3, 19], "integr": [3, 19, 27, 30, 38, 40], "deliveri": [3, 19], "ci": [3, 40], "cd": [3, 30, 40], "autom": [3, 9, 19, 34, 40], "provid": [3, 9, 14, 19, 27, 30, 32, 38, 40, 41, 50], "detail": [3, 9, 14, 19, 27, 40], "guidanc": [3, 19, 50], "pipelin": [3, 19, 40], "enabl": [3, 27, 34, 38], "test": [3, 40], "updat": 3, "scale": [3, 40], "cluster": [3, 19, 27, 30, 34, 40, 41], "strategi": 3, "tool": [3, 19, 30, 32, 40, 41], "manag": [3, 9, 19, 27, 30, 34, 38, 40, 50], "expand": 3, "infrastructur": [3, 14, 19, 40, 41], "grow": 3, "ensur": [3, 9, 14, 19, 27, 30, 32, 34, 40, 41, 50], "applic": [3, 9, 19, 27, 30, 32, 34, 40, 41], "remain": 3, "perform": [3, 9, 19, 40, 41, 50], "final": [3, 9, 19, 27, 32], "tune": [3, 40], "offer": [3, 14, 19, 38, 40, 50], "expert": [3, 9], "tip": [3, 9], "techniqu": [3, 50], "reduc": 3, "latenc": 3, "improv": [3, 14], "resourc": [3, 9, 14, 19, 27, 34, 40, 50], "util": [3, 40], "By": [3, 9, 14, 19, 27, 32, 38, 40, 41, 50], "end": [3, 19, 27, 32, 38, 41], "equip": [3, 27], "knowledg": [3, 50], "larg": [3, 40], "grade": 3, "workflow": [3, 9, 19, 27, 38, 40], "fine": 3, "system": [3, 30, 32, 38, 50], "maximum": 3, "effici": [3, 9, 27, 38, 40], "comprehens": [9, 41], "document": [9, 14, 27, 30, 34], "how": [9, 14, 19, 27, 30, 32, 38, 41, 50], "us": [9, 19, 27, 30, 32, 34, 41, 50], "line": [9, 30, 34, 40], "interfac": [9, 27, 40], "develop": [9, 14, 27, 30, 38, 40, 50], "essenti": [9, 14, 19, 27, 32, 34], "want": [9, 30], "fulli": 9, "leverag": [9, 14, 27, 50], "platform": [9, 14, 19, 27, 32, 34, 38, 40, 41], "": [9, 14, 19, 27, 32, 34, 38, 40, 41, 50], "power": [9, 40], "flexibl": [9, 30, 38], "streamlin": [9, 38, 40], "syntax": [9, 40], "explain": [9, 19, 50], "structur": [9, 27, 40, 41], "includ": [9, 19, 30], "option": [9, 14, 32, 38], "flag": 9, "argument": 9, "can": [9, 14, 30, 38], "execut": [9, 32, 34], "correctli": 9, "list": [9, 40, 50], "find": [9, 14, 27, 30, 40, 41], "descript": 9, "all": [9, 34], "avail": [9, 34, 40], "along": 9, "exampl": [9, 32, 40], "explan": [9, 27], "real": [9, 27, 40], "world": [9, 27, 40], "scenario": [9, 27], "To": [9, 32, 34], "work": [9, 40], "more": [9, 30, 32, 38, 40], "usag": [9, 30, 50], "pattern": [9, 40], "outlin": [9, 14, 41], "common": [9, 19, 38, 40, 50], "approach": [9, 30], "combin": 9, "allow": [9, 27, 30, 38, 40], "complex": [9, 38, 40], "eas": [9, 40], "minim": [9, 50], "error": 9, "maintain": [9, 27, 38, 41], "clean": 9, "histori": 9, "master": [9, 40], "materi": 9, "gain": [9, 50], "confid": 9, "skill": 9, "need": [9, 14, 27, 34, 38, 40, 50], "effect": [9, 14, 27, 34, 50], "ani": [9, 30, 34, 40], "from": [9, 14, 30, 34, 40], "connect": [14, 40, 50], "get": [14, 34, 40, 50], "contribut": [14, 40], "reactor": [14, 34], "engag": 14, "broader": 14, "whether": [14, 40, 41, 50], "re": [14, 40, 50], "troubleshoot": [14, 19, 40], "an": [14, 27, 32, 40], "issu": [14, 19, 40, 41, 50], "evolut": 14, "link": 14, "guidelin": [14, 41], "make": [14, 27, 30, 34, 40], "most": [14, 27, 40], "driven": 14, "ecosystem": [14, 40], "direct": [14, 30], "access": [14, 30, 34], "forum": 14, "chat": 14, "channel": 14, "offici": [14, 30], "where": 14, "ask": [14, 40], "question": [14, 40], "share": 14, "other": [14, 19], "If": 14, "encount": [14, 50], "bug": 14, "assist": 14, "specif": [14, 19, 27, 38, 40], "file": [14, 34, 40], "instruct": [14, 19, 30, 32, 40], "report": 14, "problem": [14, 19, 50], "team": [14, 40], "address": [14, 50], "concern": 14, "promptli": 14, "those": [14, 30], "interest": 14, "code": 14, "write": 14, "idea": [14, 32], "involv": 14, "project": [14, 27, 40, 41], "particip": 14, "its": [14, 19, 27, 38, 40], "growth": 14, "addition": [14, 34, 38, 50], "paid": [14, 40], "premium": 14, "organ": [14, 27, 30], "dedic": 14, "abl": [14, 50], "both": [14, 27, 40], "resolv": [14, 19, 50], "profession": [14, 40], "when": [14, 50], "set": [19, 30, 32], "up": [19, 32], "smooth": [19, 50], "suit": [19, 40], "deploi": [19, 32, 40], "argocd": [19, 40], "terraform": [19, 40], "core": [19, 30, 38, 40, 41], "foundat": [19, 27, 32, 41], "variabl": 19, "kei": [19, 27, 32, 38], "paramet": 19, "affect": 19, "interact": [19, 27, 32, 34], "seamlessli": [19, 30, 40], "proper": [19, 34], "while": [19, 40, 50], "walk": [19, 30, 32], "through": [19, 27, 30, 32, 38], "provis": 19, "solut": [19, 38, 40, 50], "mai": 19, "aris": 19, "dure": 19, "ongo": 19, "quickli": [19, 50], "have": [19, 27, 30, 32], "clear": [19, 40, 50], "understand": [19, 27, 32, 38], "case": 19, "devop": [19, 40], "principl": [27, 38, 40], "architectur": [27, 40, 41], "behind": [27, 32, 38], "capabl": [27, 40], "explor": [27, 32, 38, 40], "emphas": 27, "modular": [27, 40, 41], "extens": [27, 38, 40, 41], "tailor": [27, 38], "featur": [27, 32, 38, 41, 50], "extend": [27, 40], "function": [27, 34, 38, 40, 41], "custom": [27, 30, 38, 40, 41], "modul": [27, 41], "enhanc": [27, 32, 38, 40], "nativ": [27, 40], "easier": 27, "unifi": 27, "command": [27, 30, 32, 34, 40], "also": 27, "depth": 27, "cli": [27, 30, 34, 40], "which": 27, "intuit": 27, "hierarchi": 27, "workload": 27, "within": [27, 34, 41], "clariti": 27, "terminologi": [27, 40], "defin": 27, "term": 27, "frequent": [27, 40, 50], "solid": [27, 32], "grasp": 27, "guid": [30, 32, 34, 38, 40, 41], "two": 30, "depend": [30, 32], "prefer": 30, "either": 30, "add": [30, 40], "path": [30, 34], "easi": [30, 34, 40], "discov": 30, "familiar": 30, "must": [30, 34], "follow": [30, 32, 34, 41], "here": 30, "http": [30, 34], "sig": 30, "k8": 30, "io": 30, "doc": [30, 34], "note": [30, 40], "we": [30, 32], "plan": 30, "registri": 30, "until": 30, "complet": [30, 40], "process": [30, 34, 38], "creat": [30, 38, 41], "zimagi": 30, "github": [30, 40], "run": [30, 34, 50], "copi": 30, "past": 30, "sequenc": 30, "termin": 30, "index": 30, "com": [30, 34], "kube": 30, "git": [30, 34], "onc": [30, 32], "verifi": 30, "now": 30, "inform": 30, "refer": [30, 40], "altern": 30, "standalon": 30, "method": 30, "outsid": 30, "curl": [30, 34], "download": [30, 34], "properli": [30, 34], "addit": [30, 38], "binari": 30, "locat": 30, "machin": 30, "latest": 30, "releas": [30, 40], "reactor_vers": 30, "0": 30, "x": 30, "mkdir": 30, "p": 30, "home": 30, "fsslo": 30, "tar": 30, "gz": 30, "zxvf": 30, "directori": 30, "alreadi": 30, "done": 30, "bashrc": 30, "profil": 30, "export": 30, "check": 30, "version": [30, 34], "session": 30, "step": [32, 40, 50], "begin": 32, "review": 32, "requir": [32, 40], "instal": [32, 34, 40], "quick": [32, 40], "first": 32, "deepen": 32, "concept": [32, 40], "overview": 32, "them": 32, "simpl": [32, 40], "demonstr": 32, "give": [32, 38, 40], "hand": 32, "advanc": [32, 38, 40], "let": 32, "dive": [32, 40], "support": [32, 40], "1": 32, "kubectl": 32, "krew": 32, "plugin": 32, "2": 32, "local": [32, 40], "script": [32, 34, 40], "librari": 32, "A": [32, 40], "befor": [34, 41], "meet": 34, "These": 34, "prerequisit": 34, "linux": 34, "modern": 34, "distribut": 34, "e": 34, "g": 34, "ubuntu": 34, "cento": 34, "debian": 34, "fedora": 34, "maco": 34, "10": 34, "15": 34, "catalina": 34, "later": 34, "window": 34, "subsystem": 34, "wsl": 34, "softwar": 34, "bash": 34, "shell": 34, "ha": 34, "control": [34, 38, 40], "repositori": 34, "compon": [34, 38, 41, 50], "sure": 34, "scm": 34, "book": 34, "en": 34, "v2": 34, "start": [34, 40], "python": 34, "3": 34, "certain": 34, "pyyaml": 34, "packag": 34, "pars": 34, "yaml": 34, "www": 34, "org": 34, "pip": 34, "docker": 34, "engin": [34, 40], "container": [34, 40], "web": 34, "variou": [34, 38, 41], "base": [34, 38, 40], "servic": 34, "se": 34, "openssl": 34, "certif": 34, "encrypt": 34, "protocol": 34, "necessari": 34, "commun": [34, 50], "sourc": 34, "abov": 34, "proceed": 34, "one": 38, "strength": 38, "ad": 38, "remov": [38, 40], "introduc": [38, 41], "philosophi": 38, "focus": [38, 41, 50], "reusabl": 38, "easili": [38, 40], "without": [38, 41], "disrupt": [38, 50], "hook": [38, 40], "mechan": 38, "intercept": 38, "modifi": 38, "behavior": [38, 50], "stage": 38, "templat": [38, 40], "blueprint": 38, "task": 38, "empow": [38, 40], "build": [38, 40], "adapt": [38, 40], "unnecessari": 38, "welcom": 40, "simpler": 40, "highli": 40, "customiz": 40, "administr": 40, "readtor": 40, "built": [40, 50], "align": 40, "multi": 40, "It": 40, "over": 40, "embrac": 40, "still": 40, "simplic": 40, "out": [40, 41], "box": 40, "directli": 40, "seamless": 40, "same": 40, "do": 40, "singl": 40, "minikub": 40, "node": 40, "cloud": 40, "compat": 40, "seek": 40, "wai": 40, "respons": 40, "architect": 40, "new": 40, "experienc": 40, "discord": 40, "log": [40, 50], "debug": [40, 50], "monitor": [40, 50], "changelog": 40, "stabil": 41, "entir": 41, "valid": 41, "thei": 41, "reach": 41, "methodologi": 41, "robust": 41, "framework": 41, "fundament": 41, "critic": 41, "expect": 41, "insight": [41, 50], "sacrif": 41, "lastli": 41, "consist": 41, "under": 41, "condit": 41, "laid": 41, "thoroughli": 41, "everi": 41, "mitig": 41, "earli": 41, "high": 41, "qualiti": 41, "diagnos": 50, "unexpect": 50, "bottleneck": 50, "identifi": 50, "challeng": 50, "fix": 50, "back": 50, "track": 50, "deeper": 50, "analysi": 50, "root": 50, "caus": 50, "relat": 50, "slow": 50, "ineffici": 50, "network": 50, "between": 50, "prevent": 50, "overload": 50, "smoothli": 50, "downtim": 50}, "objects": {}, "objtypes": {}, "objnames": {}, "titleterms": {"ci": 0, "cd": 0, "autom": 0, "perform": [1, 49], "tune": 1, "product": 2, "setup": 2, "reactor": [3, 9, 19, 27, 30, 32, 38, 40, 41, 42, 43, 44, 45, 50], "advanc": 3, "usag": [3, 10, 40, 51], "scale": 4, "kubernet": [4, 18, 24], "cluster": 4, "releas": 5, "note": 5, "changelog": 5, "best": 6, "practic": 6, "command": [7, 8, 9], "list": 7, "syntax": 8, "cli": [9, 22], "refer": 9, "pattern": 10, "contribut": 11, "file": 12, "issu": [12, 46, 47], "paid": 13, "support": [13, 14, 15, 34], "commun": [14, 40], "test": [14, 41, 42, 43, 44, 45], "link": [15, 40], "argocd": 16, "configur": [16, 17, 18, 19, 20, 21], "core": [17, 27, 43], "guid": [19, 31, 36], "terraform": 20, "troubleshoot": [21, 49, 50], "structur": [22, 26], "kei": [23, 40], "terminologi": 23, "integr": 24, "modular": [25, 38], "extens": [25, 35, 44], "project": [26, 45], "concept": [27, 29], "frequent": 28, "ask": 28, "question": 28, "basic": 29, "instal": 30, "option": 30, "1": 30, "kubectl": 30, "krew": 30, "plugin": 30, "prerequisit": 30, "step": 30, "2": 30, "local": 30, "script": 30, "librari": 30, "quick": 31, "start": [31, 32], "get": 32, "A": 33, "simpl": 33, "exampl": 33, "system": [34, 40], "requir": 34, "oper": 34, "tool": 34, "depend": 34, "principl": 36, "hook": 37, "architectur": [38, 42], "templat": 39, "document": 40, "introduct": 40, "overview": 40, "what": 40, "i": 40, "featur": 40, "who": 40, "should": 40, "us": 40, "how": 40, "thi": 40, "can": 40, "help": 40, "you": 40, "fundament": 40, "mainten": 40, "common": 46, "solut": 46, "connect": 47, "log": 48, "debug": 48, "resourc": 51, "monitor": 51}, "envversion": {"sphinx.domains.c": 2, "sphinx.domains.changeset": 1, "sphinx.domains.citation": 1, "sphinx.domains.cpp": 8, "sphinx.domains.index": 1, "sphinx.domains.javascript": 2, "sphinx.domains.math": 2, "sphinx.domains.python": 3, "sphinx.domains.rst": 2, "sphinx.domains.std": 2, "sphinx.ext.viewcode": 1, "sphinx": 57}, "alltitles": {"CI/CD and Automation": [[0, "ci-cd-and-automation"]], "Performance Tuning": [[1, "performance-tuning"]], "Production Setup": [[2, "production-setup"]], "Reactor Advanced Usage": [[3, "reactor-advanced-usage"]], "Advanced Usage": [[3, null]], "Scaling Kubernetes Clusters": [[4, "scaling-kubernetes-clusters"]], "Release Notes and Changelog": [[5, "release-notes-and-changelog"]], "Best Practices": [[6, "best-practices"]], "Command List": [[7, "command-list"]], "Command Syntax": [[8, "command-syntax"]], "Reactor CLI Command Reference": [[9, "reactor-cli-command-reference"]], "CLI Command Reference": [[9, null]], "Usage Patterns": [[10, "usage-patterns"]], "Contributing": [[11, "contributing"]], "Filing Issues": [[12, "filing-issues"]], "Paid Support": [[13, "paid-support"]], "Community and Support": [[14, "community-and-support"]], "Testing": [[14, null], [41, null]], "Support Links": [[15, "support-links"]], "ArgoCD Configuration": [[16, "argocd-configuration"]], "Core Configuration": [[17, "core-configuration"]], "Kubernetes Configuration": [[18, "kubernetes-configuration"]], "Reactor Configuration Guide": [[19, "reactor-configuration-guide"]], "Configuration Guide": [[19, null]], "Terraform Configuration": [[20, "terraform-configuration"]], "Configuration Troubleshooting": [[21, "configuration-troubleshooting"]], "CLI Structure": [[22, "cli-structure"]], "Key Terminology": [[23, "key-terminology"]], "Kubernetes Integration": [[24, "kubernetes-integration"]], "Modularity and Extensibility": [[25, "modularity-and-extensibility"]], "Project Structure": [[26, "project-structure"]], "Reactor Core Concepts": [[27, "reactor-core-concepts"]], "Core Concepts": [[27, null]], "Frequently Asked Questions": [[28, "frequently-asked-questions"]], "Basic Concepts": [[29, "basic-concepts"]], "Installation": [[30, "installation"]], "Option 1: Install Reactor as a Kubectl Krew Plugin": [[30, "option-1-install-reactor-as-a-kubectl-krew-plugin"]], "Prerequisites": [[30, "prerequisites"], [30, "id1"]], "Installation Steps": [[30, "installation-steps"], [30, "id2"]], "Option 2: Install Reactor as a Local Script Library": [[30, "option-2-install-reactor-as-a-local-script-library"]], "Quick Start Guide": [[31, "quick-start-guide"]], "Getting Started with Reactor": [[32, "getting-started-with-reactor"]], "Getting Started": [[32, null]], "A Simple Example": [[33, "a-simple-example"]], "System Requirements": [[34, "system-requirements"]], "Supported Operating Systems": [[34, "supported-operating-systems"]], "Required Tools and Dependencies": [[34, "required-tools-and-dependencies"]], "Extensions": [[35, "extensions"]], "Guiding Principles": [[36, "guiding-principles"]], "Hooks": [[37, "hooks"]], "Reactor Modular Architecture": [[38, "reactor-modular-architecture"]], "Modular Architecture": [[38, null]], "Templates": [[39, "templates"]], "Reactor System Documentation": [[40, "reactor-system-documentation"]], "Introduction and Overview": [[40, "introduction-and-overview"]], "What is reactor?": [[40, "what-is-reactor"]], "Key Features:": [[40, "key-features"]], "Who Should Use Reactor?": [[40, "who-should-use-reactor"]], "How This Documentation Can Help You": [[40, "how-this-documentation-can-help-you"]], "Links": [[40, null]], "Fundamentals": [[40, null]], "Usage": [[40, null]], "Maintenance": [[40, null]], "Community": [[40, null]], "Reactor Testing": [[41, "reactor-testing"]], "Reactor Test Architecture": [[42, "reactor-test-architecture"]], "Reactor Core Testing": [[43, "reactor-core-testing"]], "Reactor Extension Testing": [[44, "reactor-extension-testing"]], "Reactor Project Testing": [[45, "reactor-project-testing"]], "Common Issues and Solutions": [[46, "common-issues-and-solutions"]], "Connectivity Issues": [[47, "connectivity-issues"]], "Logging and Debugging": [[48, "logging-and-debugging"]], "Performance Troubleshooting": [[49, "performance-troubleshooting"]], "Reactor Troubleshooting": [[50, "reactor-troubleshooting"]], "Troubleshooting": [[50, null]], "Resource Usage Monitoring": [[51, "resource-usage-monitoring"]]}, "indexentries": {}})