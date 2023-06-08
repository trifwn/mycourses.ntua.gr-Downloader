"""
Downloads all the courses from the COURSES.txt file.
"""

import subprocess
import sys
import os
from time import sleep


def get_course(course: str) -> None:
    """Gets the course with the given name."""
    print(f"Getting course {course}")
    cwd = os.getcwd()
    os.chdir(f"{cwd}")
    username: str = input("Enter username: ")
    password: str = input("Enter password: ")

    result = subprocess.run(
        [
            f"{cwd}/my_get.sh",
            "-c",
            course,
            "--username", username,
            "--password", password
        ],
        capture_output=True,
        text=True,
        check=True
    )
    print(result.stderr)
    print(result.stdout)
    if result.returncode != 0:
        print(f"Failed to get course {course}")
        sys.exit(1)
    print(f"Finished getting course {course}")


def main() -> None:
    """ Runs the program"""
    with open("COURSES.txt", encoding='UTF-8') as file:
        courses: list[str] = file.readlines()

    parsed_courses: list[str] = []
    for course in courses:
        parsed_courses.append(course[:-1])
    print(parsed_courses)

    for course in parsed_courses:
        get_course(course)
        sleep(1)


if __name__ == "__main__":
    main()
