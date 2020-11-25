"""
Wren CLI does not have a json reader
so we must use Python to generate a proper html
for this json
and append it to the index

TODO: Change to Wren data structures?
"""

import json
import os

pwd = os.getcwd()

def load():
  with open(f"{pwd}/content/index/projects.json") as f:
    return json.loads(f.read())

def write(content):
  with open(f"{pwd}/content/index/index.html", "w") as f:
    f.write(content)
    f.close()

def main():
  data = load()
  out = ""
  for category in data["projects"]:

    out += f"""
    <h3>{category["emoji"]} · {category["title"]}</h3>"""

    for item in category["items"]:

      stack = ""
      for tech in item["tech"]:
        stack += f"""<li>{tech}</li>"""

      out += f"""
  <h4>
    <a href="{item["url"]}">{item["name"]}</a>
    <small>({item["start"]} - {item["end"]})</small>
  </h4>
  <p>
  {item["about"]}
  </p>
  <div className="repo-card" data-repo="{item["repo"]}"></div>
  <h5>Tech Stack</h5>
  <ul>
    {stack}
  </ul>
      """

  write(out.strip())

if __name__ == "__main__":
  main()
