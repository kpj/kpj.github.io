# cookiecutter-python: An opinionated template for Python packages

Starting the development of a new Python package is like discovering a whole new world all over again. However, before the enlightening stream of pure creative energy can be directed at crafting the actual idea, a set of repetitive tasks needs to be performed.
This usually includes the setup of automated testing and linting infrastructure, package publishing pipelines, and more. Since the best practice guidelines are ever changing, keeping up and remembering what's new can be daunting.

[cookiecutter-python](https://github.com/kpj/cookiecutter-python) washes all these troubles away and let's you start cracking right away. Simply execute `cookiecutter https://github.com/kpj/cookiecutter-python`, answer a few fun questions, and your project is ready to go.

Right out-of-the-box it will support:
* Package management using [poetry](https://github.com/python-poetry/poetry)
* GitHub Actions workflows for automated CI/CD
* Testing using [pytest](https://github.com/pytest-dev/pytest)
* Linting using [black](https://github.com/psf/black)
* Semantic versioning using [bump2version](https://github.com/c4urself/bump2version)
* Automated dependency updates using [dependabot](https://github.com/dependabot/dependabot-core)
