const axios = require('axios');
const jsonwebtoken = require('jsonwebtoken');
const NodeRSA = require('node-rsa');

const webKeyUrl = process.env.JWKS_URL || 'https://accounts.eu1.gigya.com/accounts.getJWTPublicKey';

const deserializeKey  = (key) => key
  .replace(/-/g, '+')
  .replace(/_/g, '/');

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
  const jwks = await axios.get(webKeyUrl);
  const publicKey = jwks.data;
  const modulus = Buffer.from(deserializeKey(publicKey.n), 'base64')
  const exponent = (typeof publicKey.e === 'number')
      ? publicKey.e
      : Buffer.from(publicKey.e, 'base64')
  
  const pubKey = new NodeRSA()
      pubKey.importKey({
        e: exponent,
        n: modulus
      }, 'components-public')
  const pubPem = pubKey
        .exportKey('pkcs1-public')
        .toString('utf8')

  try {
    const jws = jsonwebtoken
      .verify(idToken, pubPem, { algorithms: ['RS256'] })

    return responsePolicy("Allow", event.routeArn, jws);
  } catch (error) {
    console.error(JSON.stringify({ message: error.message }));
  }

  return responsePolicy("Deny", event.routeArn, {});
}

module.exports = { handler };
