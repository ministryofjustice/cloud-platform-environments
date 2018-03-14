function (user, context, callback) {
  var request = require('request');

  var github_org_whitelist = ['ministryofjustice'];

  // Apply to 'github' connections only
  if(context.connection === 'github'){
    var github_identity = _.find(user.identities, { connection: 'github' });

    // Only allow members of whitelisted Github orgs
    var orgs_req = {
      url: 'https://api.github.com/user/orgs',
      headers: {
          'Authorization': 'token ' + github_identity.access_token,
          'User-Agent': 'request'
      }
    };

    request(orgs_req, function (err, resp, body) {
      if (resp.statusCode !== 200) {
        return callback(new Error('Error retrieving orgs from github: ' + body || err));
      }

      var user_orgs = JSON.parse(body).map(function(org){
        return org.login;
      });

      var authorized = github_org_whitelist.some(function(org){
        return user_orgs.indexOf(org) !== -1;
      });

      if (!authorized) {
        return callback(new UnauthorizedError('Access denied.'));
      }
    });

    // Get Github team list and add to group claim in user's OIDC token
    // 
    // Custom claims must be prefixed with a domain.
    //
    // Team names are prefixed with 'github' to distinguish them from
    // groups from other identity providers
    var teams_req = {
      url: 'https://api.github.com/user/teams',
      headers: {
        'Authorization': 'token ' + github_identity.access_token,
        'User-Agent': 'request'
      }
    };

    request(teams_req, function (err, resp, body) {
      if (resp.statusCode !== 200) {
        return callback(new Error('Error retrieving teams from github: ' + body || err));
      }

      var git_teams = JSON.parse(body).map(function (team) {
        return "github:" + team.slug;
      });

      var namespace = "https://k8s.integration.dsd.io/";
      context.idToken[namespace + "groups"] = git_teams;

      return callback(null, user, context);
    });

  } else {
    callback(null, user, context);
  }
}
