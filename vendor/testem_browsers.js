var fs = require('fs');

var testemConfig;

try {
  if(fs.existsSync(`${process.argv[2]}/testem.js`)) {
    testemConfig = require(`${process.argv[2]}/testem.js`);
  } else if(fs.existsSync(`${process.argv[2]}/.testem.js`)) {
    testemConfig = require(`${process.argv[2]}/.testem.js`);
  } else {
    process.exit();
  }
} catch(e) {
  process.exit();
}

var browsers = {
  "launch_in_ci": testemConfig.launch_in_ci
};
console.log(JSON.stringify(browsers));
