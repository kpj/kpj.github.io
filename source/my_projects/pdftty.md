# pdftty: A PDF viewer for the terminal

Viewing PDFs is understandably something you typically only want to do with access to a proper GUI.
However, under special circumstances, you might feel the temptation to open and view a PDF while staying in the terminal. This might be because you forgot to enable X forwarding when starting your SSH connection or simply for the fun of it.

Looking for a solution online will tell you to [convert](https://unix.stackexchange.com/questions/41362/view-pdf-file-in-terminal) the PDF to text using one of many methods.
But what happens if you are curious about some of the pictures or want to really make sure that the layout is kept?

[pdftty](https://github.com/kpj/pdftty) visualizes the PDF in your terminal by converting each page to a PNG image which is then rendered using ANSI escape sequences. Due to its modular structure, other engines (e.g. libcaca) can be easily implemented. Using the arrow keys to switch pages and `+`/`-` to zoom makes exploring PDFs a whole new adventure.

![Example ANSI](pdftty_resources/example_ansi.png)
![Example CACA](pdftty_resources/example_caca.png)

In addition to its obvious use, `pdftty` internally follows the [Model–view–controller](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) design pattern which makes extending it fun and rewarding.
