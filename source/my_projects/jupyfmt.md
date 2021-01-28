# jupyfmt: The uncompromising Jupyter notebook formatter

Jupyter notebooks are both a blessing and a curse, depending on what you want to do and who you ask.
On the one hand, they are undoubtedly making sharing data analysis results, providing code examples, and quickly exploring new datasets quite comfortable. On the other hand, maintaining proper coding standards or following the DRY principle are exercise of will and determination.

The ability to automatically assert that certain common coding standards (such as consistent code formatting, or cells being executed in the right order) are met is very useful. Not only while developing on your own machine, but also when quality controlling all new commits as part of your CI/CD workflow.

[jupyfmt](https://github.com/kpj/jupyfmt) makes this possible by either formatting the code cells of your notebook in-place or alternatively simply checking whether changes would be needed.

For example, the check of a dummy notebook could look like this:

```bash
$ jupyfmt --check --compact-diff Notebook.ipynb
--- Notebook.ipynb - Cell 1
+++ Notebook.ipynb - Cell 1
@@ -1,2 +1,2 @@
-def foo (*args):
+def foo(*args):
     return sum(args)

--- Notebook.ipynb - Cell 2
+++ Notebook.ipynb - Cell 2
@@ -1 +1 @@
-foo(1, 2,3)
+foo(1, 2, 3)

2 cell(s) would be changed 😬
1 cell(s) would be left unchanged 🎉

1 file(s) would be changed 😬
```

By providing directories instead of notebook paths, this can be directly integrated, e.g., with GitHub Actions to automatically assert that all notebook related commits are of high-quality (at least syntactically).
