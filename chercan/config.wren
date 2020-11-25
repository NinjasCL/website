
class Template {
  // Which template to use if none is given
  // default.wren.html
  static default {"default"}
}

class Config {
  // Sets the default theme
  static theme {"ninjas"}

  static template {Template}

  // Sets the build output dir
  static out {"dist"}
}
