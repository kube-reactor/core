"""
NOTE:
    The below Cookiecutter hook maintains a Reactor based CookieCutter project initialization

    * It managed the OS license and community files
"""

import os
import random
import string


TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "


def remove_open_source_files():
    file_names = ["LICENSE"]
    for file_name in file_names:
        os.remove(file_name)


def main():
    if "{{ cookiecutter.open_source_license }}" == "none":
        remove_open_source_files()

    print(SUCCESS + "Project initialized." + TERMINATOR)


if __name__ == "__main__":
    main()
