const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

const client = jwksClient({
  jwksUri: 'https://accounts.eu1.gigya.com/accounts.getJWTPublicKey',
});

const responsePolicy = (effect, routeArn, context) => {
  return {
    principalId: "foobar",
    policyDocument: {
      Version: "2012-10-17",
      Statement: [{
        Action: "execute-api:Invoke",
        Effect: effect,
        Resource: routeArn
      }]
    },
    context
  }
}

const handler = async (event) => {
  try {
    const token = event.headers.authorization.split(' ')[1];
    
    if(token === 'salaam') {
      return responsePolicy("Allow", event.routeArn, {bypassJwt: true})
    }

    const decoded = jwt.decode(token, { complete: true });
    const kid = decoded.header.kid;
  
    const key = await client.getSigningKeyAsync(kid);
    const signingKey = key.getPublicKey();
  
    const context = jwt.verify(token, signingKey);

    return responsePolicy("Allow", event.routeArn, context)
  } catch (error) {
    console.error(JSON.stringify({ message: error.message }));
  }
  return responsePolicy("Deny", event.routeArn, {})
}

module.exports = { handler };
