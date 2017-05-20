var testemConfig;

try {
  var testemConfig = require(`${process.argv[2]}/testem`);
} catch(e) {
  process.exit();
}

var browsers = {
  "browsers": testemConfig.launch_in_ci
};
console.log(JSON.stringify(browsers));
