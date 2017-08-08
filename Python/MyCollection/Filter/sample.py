datafile = open("logcat.txt")

section = None
found   = []

match   = set(["Message: 401"])  # can be multiple items

for line in datafile:
    line = line.strip()
    if line.startswith("[") and line.endswith("]"):
        section = line.strip("[]")
    elif line in match:
        found.append(section)

	print found