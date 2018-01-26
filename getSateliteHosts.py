#este script trae todos los hosts que son Centos y estan incorrectamente suscriptos al satellite se agrego este comentario
#the API call client.system.getRunningKernel() would likely work.
!/usr/bin/python
import xmlrpclib

SATELLITE_URL = "https://satellite.example.com"
SATELLITE_LOGIN = "foo"
SATELLITE_PASSWORD = "bar"

client = xmlrpclib.Server(SATELLITE_URL, verbose=0)

key = client.auth.login(SATELLITE_LOGIN, SATELLITE_PASSWORD)

def search(name, dicts, key="name"):
try:
return (item for item in dicts if item[key] == name).next()
except:
return None

systems = client.system.listSystems(key)
for system in systems:
packages = client.system.listPackages(key,system['id'])
rel = search('redhat-release',packages)
if not rel:
rel = search('redhat-release-server',packages)
if rel:
print "%s %s" % ( system['name'], rel['release'])
else:
print "%s Unknown" % ( system['name'])
