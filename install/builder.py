#!/usr/bin/env python

import re
import os
import base64

comment_regex = re.compile("\s*#.*")
include_source_regex = re.compile("^(source|\.) (.*)")
render_template_regex = re.compile("^# RENDER TEMPLATE (.*) INTO (.*) (IGNORE|OVERRIDE)")


def minify_line(line):
    line = line.strip()
    if not comment_regex.match(line):
        if line:
            return line + "\n"
    return ""


class BashBundler:
    def __init__(self, entrypoint, vendor_directory, output_file=None):
        self.entrypoint = entrypoint
        self.minify_sourced_files = True
        if output_file:
            self.output_file = output_file
        else:
            self.output_file = "{}.bundle.sh".format(entrypoint)
        self.mustache_included = False
        self.vendor_directory = vendor_directory

    def bundle(self):
        with open(self.output_file, "w") as w:
            with open(self.entrypoint) as e:
                os.chdir(os.path.dirname(os.path.abspath(self.entrypoint)))
                for line in self.bundle_file(e, minify=False):
                    w.write(line)

    def bundle_file(self, file_descriptor, minify=True):
        previous_line = ''
        for line in file_descriptor:
            other_include = include_source_regex.match(line)
            template_match = render_template_regex.match(line)
            if other_include:
                with open(other_include.group(2)) as other_file:
                    yield "# START-INCLUDE: {}\n".format(other_include.group(2))
                    for other_line in self.bundle_file(other_file):
                        yield other_line
                    yield "\n# END-INCLUDE:  {}\n".format(other_include.group(2))
            elif template_match:
                for line in self.bundle_template(template_match.group(1), template_match.group(2), template_match.group(3)):
                    yield line
            else:
                if minify:
                    minified = minify_line(line)
                    if minified:
                        if not previous_line.strip() and not minified.strip():
                            # 2 empty lines
                            pass
                        else:
                            previous_line = minified
                            yield minified
                else:
                    if not previous_line.strip() and not line.strip():
                        # 2 empty lines
                        pass
                    else:
                        previous_line = line
                        yield line

        yield f"""\necho "$(date '+%Y-%m-%d %H:%M:%S') Finished {file_descriptor.name}" """


    def bundle_template(self, from_file, to_location, flag):
        yield "# START-RENDERING TEMPLATE \n"
        with open(from_file, "rb") as f:
            yield "regex='\$\{([a-zA-Z_][a-zA-Z_0-9]*)\}'\n"
            yield 'sudo echo "Rendering {} into {}"\n'.format(from_file, to_location)
            file_data = base64.b64encode(f.read())
            yield 'template=$(echo "{}"'.format(file_data.decode('ascii')) + " | base64 --decode)"
            yield """
    while IFS= read -r line; do
        newline=$line
        while [[ "$newline" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
            LHS=${BASH_REMATCH[1]}
            RHS="$(eval echo "\"$LHS\"")"
            newline=${line//$LHS/$RHS}
        done
        echo "$newline"
    done < <(printf "%s\\n" "$template") | sudo tee """ + to_location + " > /dev/null \n"
        yield "# END-RENDERING TEMPLATE \n"


if __name__ == '__main__':
    ignore_dirs = ['vendor', 'common', 'docs']
    d = os.path.dirname(os.path.abspath(__file__))
    os.chdir(d)
    vendor_directory = os.path.join(d, 'vendor')
    directories = [os.path.join(d, o) for o in os.listdir(d) if os.path.isdir(os.path.join(d, o))]
    for o in os.listdir(d):
        if o not in ignore_dirs:
            directory = os.path.join(d, o)
            if os.path.isdir(directory):
                for file_name in os.listdir(directory):
                    if file_name.endswith(".sh") and not file_name.endswith(".bundle.sh"):
                        entry_point = os.path.join(directory, file_name)
                        print("Bundeling {}".format(file_name))
                        b = BashBundler(entry_point, vendor_directory=vendor_directory)
                        b.bundle()
