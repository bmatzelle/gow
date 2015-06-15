@setlocal
@set "LESSOPEN=|gzip -cdfq -- %%s"
@less %*

