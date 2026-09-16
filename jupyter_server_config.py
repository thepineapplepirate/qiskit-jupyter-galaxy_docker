# See http://ipython.org/ipython-doc/1/interactive/public_server.html for more information.
# Configuration file for ipython-notebook.
import os
import psutil

c = get_config()
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.profile = u'default'
c.IPKernelApp.matplotlib = 'inline'

CORS_ORIGIN = ''
CORS_ORIGIN_HOSTNAME = ''

if os.environ['CORS_ORIGIN'] != 'none':
    CORS_ORIGIN = os.environ.get('CORS_ORIGIN', '')
    CORS_ORIGIN_HOSTNAME = CORS_ORIGIN.split('://')[1]

# Jupyter Server 2.x rejects the old multi-line CSP when CORS_ORIGIN is empty:
# it produced an invalid `ws://` source and newline-containing header value.
# Keep the tool embeddable in Galaxy while emitting one valid header value.
origin_sources = " %s" % CORS_ORIGIN if CORS_ORIGIN else ""
headers = {
    'X-Frame-Options': 'ALLOWALL',
    'Content-Security-Policy': (
        "default-src 'self'%s; "
        "img-src 'self' data: blob:%s; "
        "connect-src 'self' ws: wss:%s; "
        "style-src 'unsafe-inline' 'self'%s; "
        "script-src 'unsafe-inline' 'unsafe-eval' 'self'%s;"
        % (origin_sources, origin_sources, origin_sources, origin_sources, origin_sources)
    ),
}

c.ServerApp.allow_origin = '*'
c.ServerApp.allow_credentials = True

c.ServerApp.base_url = '%s/ipython/' % os.environ.get('PROXY_PREFIX', '')
c.ServerApp.tornado_settings = {
    'static_url_prefix': '%s/ipython/static/' % os.environ.get('PROXY_PREFIX', '')
}

if os.environ.get('NOTEBOOK_PASSWORD', 'none') != 'none':
    c.ServerApp.password = os.environ['NOTEBOOK_PASSWORD']
    del os.environ['NOTEBOOK_PASSWORD']

if CORS_ORIGIN:
    c.ServerApp.allow_origin = CORS_ORIGIN

# monitor resource usage
c.ResourceUseDisplay.mem_limit = psutil.virtual_memory().total
c.ResourceUseDisplay.track_cpu_percent = True
c.ResourceUseDisplay.cpu_limit = os.cpu_count()

c.ServerApp.contents_manager_class = "jupytext.TextFileContentsManager"
c.ServerApp.tornado_settings['headers'] = headers
