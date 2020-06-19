const Page = ({ data, env }) => (
  <html lang="en">
    <head>
      <meta charSet="utf-8" />
      <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      <meta
        name="description"
        content="Is an Experimental Software Developer Group from Chile 🇨🇱. Participates in various technological projects like videogames, software and other related activities."
      />

      <meta property="og:type" content="website" />
      <meta property="og:url" content="https://ninjas.cl/" />
      <meta property="og:title" content="💻 Ninjas.cl (忍者 開発者) 🇨🇱" />
      <meta
        property="og:description"
        content="Is an Experimental Software Developer Group from Chile 🇨🇱. Participates in various technological projects like videogames, software and other related activities."
      />
      <meta property="og:image" content="https://avatars1.githubusercontent.com/u/15203190" />

      <meta property="twitter:card" content="summary_large_image" />
      <meta property="twitter:url" content="https://ninjas.cl/" />
      <meta property="twitter:title" content="💻 Ninjas.cl (忍者 開発者) 🇨🇱" />
      <meta
        property="twitter:description"
        content="Is an Experimental Software Developer Group from Chile 🇨🇱. Participates in various technological projects like videogames, software and other related activities."
      />
      <meta property="twitter:image" content="https://avatars1.githubusercontent.com/u/15203190" />

      <title>🇨🇱 Ninjas.cl 💻</title>

      <link rel="apple-touch-icon" sizes="180x180" href="/assets/img/apple-touch-icon.png" />
      <link rel="icon" type="image/png" sizes="32x32" href="/assets/img/favicon-32x32.png" />
      <link rel="icon" type="image/png" sizes="16x16" href="/assets/img/favicon-16x16.png" />
      <link rel="manifest" href="/assets/img/site.webmanifest" />

      <link href="/assets/css/main.css" rel="stylesheet" media="all" />
    </head>
    <body>
      <header>
        <section id="hero">
          <h1>
            💻 <a href="https://github.com/ninjascl">忍者 開発者 - Ninjas.cl</a>
          </h1>
          <h2>Software from 🇨🇱 (Chile) with ❤️ (love)</h2>
        </section>
        <section id="about">
          <p>
            <i>
              <a href="https://github.com/ninjascl">Ninjas.cl </a>
            </i>
            is an Experimental Software Developer Group from <i>Chile</i> 🇨🇱. It’s main focus is
            creating and participating in various technological projects like videogames, software
            and other related activities.
          </p>
          <p>
            <i>
              <a href="https://ninjas.cl">Ninjas.cl </a>
            </i>
            was started in <strong>2015</strong> by
            <a href="https://github.com/clsource"> Camilo Castro</a>.
          </p>
        </section>
        <section id="camilo">
          <h3>
            <a href="https://github.com/clsource">👨🏽‍💻 Camilo Castro</a>
          </h3>
          <p>
            Committed and result-oriented <strong>Software Engineer</strong> with experience in{" "}
            <i>Web, iOS, Blockchain, and Chatbots technologies</i>.
          </p>
          <p>
            You can contact him at: &nbsp;
            <a href="mailto:camilo@ninjas.cl" rel="noopener noreferrer">
              camilo@ninjas.cl
            </a>
          </p>
        </section>
      </header>
      <main>
        {data.projects.map((section, sindex) => (
          <React.Fragment key={sindex}>
            <h3>
              {section.emoji} {section.title}
            </h3>
            {section.items.map((item, iindex) => (
              <React.Fragment key={iindex}>
                <h4>
                  {item.url ? <a href={item.url}>{item.name}</a> : item.name}{" "}
                  <small>
                    ({item.start}
                    {item.end != "-" ? ` - ${item.end}` : ""})
                  </small>
                </h4>
                <p>{item.about}</p>

                {item.repo.length > 0 ? (
                  <div className="repo-card" data-repo={item.repo}></div>
                ) : (
                  ""
                )}

                {item.tech.length > 0 ? (
                  <>
                    <h5>Tech Stack</h5>
                    <ul>
                      {item.tech.map((tech, tindex) => (
                        <li key={tindex}>{tech}</li>
                      ))}
                    </ul>
                  </>
                ) : (
                  ""
                )}
              </React.Fragment>
            ))}
          </React.Fragment>
        ))}
      </main>
      <footer>
        <p>
          Made with ❤️ by <a href="https://ninjas.cl">Ninjas.cl</a>.{" "}
          <a href="https://oxal.org/projects/sakura/">Using Sakura CSS</a> And{" "}
          <a href="https://charge.js.org">Charge.js</a>
        </p>
      </footer>
      <script type="text/javascript" src="/assets/js/repo-card.js" />
    </body>
  </html>
);

export default Page;
