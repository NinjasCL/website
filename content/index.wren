
class Page {
  // Include any html render here

  static content {
    var path = Path + "/index.html"
    return File.read(path)
  }

  static title {"💻 Ninjas.cl (忍者 開発者) 🇨🇱"}

  static description {"Is an Experimental Software Developer Group from Chile 🇨🇱.
  Participates in various technological projects like videogames,
  software and other related activities."}

  static url {"https://ninjas.cl/"}

  static template {"index"}
}

return Page
