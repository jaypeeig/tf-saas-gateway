function extractTokenFromHeader(e) {
  if (e.authorizationToken && e.authorizationToken.split(' ')[0] === 'Bearer') {
      return e.authorizationToken.split(' ')[1];
  } else {
      return e.authorizationToken;
  }
}

function validateToken(token, callback) {
  const allow = {
    "principalId": "user",
      "policyDocument": {
          "Version": "2012-10-17",
          "Statement": [
              {
                  "Action": "execute-api:Invoke",
                  "Effect": "Allow",
                  "Resource": process.env.RESOURCE
              }
          ]
      }
  }
  
  if(token === 'Salam') {
    callback(null, allow)
  } else {
    callback("Unauthorized")
  }

}

exports.handler = (event, context, callback) => {
  const token = extractTokenFromHeader(event) || '';
  validateToken(token, callback);
}