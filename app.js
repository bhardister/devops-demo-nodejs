var port = process.env.PORT || 8181,
    http = require('http'),
    fs = require('fs'),
    html = fs.readFileSync('index.html');
    healthcheck = fs.readFileSync('healthcheck.html');

var log = function(entry) {
    fs.appendFileSync('/tmp/sample-app.log', new Date().toISOString() + ' - ' + entry + '\n');
};

var server = http.createServer(function (req, res) {
    if (req.method === 'POST') {
        var body = '';

        req.on('data', function(chunk) {
            body += chunk;
        });

        req.on('end', function() {
            if (req.url === '/') {
                log('Received message: ' + body);
            } else if (req.url = '/scheduled') {
                log('Received task ' + req.headers['x-aws-sqsd-taskname'] + ' scheduled at ' + req.headers['x-aws-sqsd-scheduled-at']);
            }

            res.writeHead(200, 'OK', {'Content-Type': 'text/plain'});
            res.end();
        });
    } else {
        if (req.url === '/' || req.url === '/index' || req.url === '/index.html') {
          res.writeHead(200);
          res.write(html);
          res.end();
        } else if (req.url === '/healthcheck'){
          res.writeHead(200);
          res.write(healthcheck);
          res.end();
        }
    }
});

// Listen on port 80, IP defaults to localhost
server.listen(port);

// Put a friendly message on the terminal
console.log('Server running at http://localhost:' + port + '/');
