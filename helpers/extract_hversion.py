try:
  for l in open('casadi_meta.cpp','r').readlines():
    if "CasadiMeta::version" in l:
      version = l.split('"')[1]
      if "+" not in version:
        break
    if "CasadiMeta::git_describe" in l:
      version = l.split('"')[1]
except:
  for l in open('casadi/config.h','r').readlines():
    if "CASADI_VERSION_STRING" in l:
      version = l.split('"')[1]
      if "+" not in version:
        break
    if "CASADI_GIT_DESCRIBE" in l:
      version = l.split('"')[1]

print(version)
