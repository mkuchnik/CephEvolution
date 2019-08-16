"""
Rewrites Orca hosts to use 40Gbps ethernet by default
"""

import re

def main():
    with open("/etc/hosts", "r+") as f:
        lines = f.read().splitlines()
        print("lines: {}".format(lines))
        p_filter = re.compile(r"h[0-9]+")
        p = re.compile(r"(h[0-9]+)-dfge")
        good_lines = []
        for l in lines:
            words = l.split()
            if len(words) > 2:
                hostname = words[1]
                if p_filter.fullmatch(hostname):
                    print("Dropping old hostname: {}".format(hostname))
                    continue
            subbed_l = p.sub(r"\1", l)
            good_lines.append(subbed_l)
        f.seek(0)
        f.write("\n".join(good_lines))

if __name__ == "__main__":
    main()