import flask
from shelljob import proc


app = flask.Flask(__name__)


@app.route('/api')
def stream():
    g = proc.Group()    
    p = g.run( ['./src1.sh', 'leslie', 'rosenzweig'] )
    def read_process():
        while g.is_pending():
            lines = g.readlines()
            for proc, line in lines:
                yield line

    return flask.Response( read_process(), mimetype= 'text/plain' )

@app.route('/')
def default():
    return "To acess the api use the path /api followed by a combination of the below parameters.<br/>https://example.com/api/search?first_name={firstName}&last_name={lastName}&location={location}&pid={pid}&custom_string={custom_string}<br/>Documentation and endpoint tester coming soon."
if __name__ == "__main__":
    app.run(debug=True)