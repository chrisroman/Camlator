const token = require('google-translate-token');

token.get(process.argv.slice(2).join(' ')).then(function(result) {
    var str = "";
    var space = "";
    for (var key in result) {
        str += space + result[key];
        space = " ";
    }
    console.log(str);
},
    function(err) {
        console.log(err);
    });
