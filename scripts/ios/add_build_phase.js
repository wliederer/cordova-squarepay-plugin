'use strict';

const xcode = require('xcode'),
    fs = require('fs'),
    path = require('path');

module.exports = function(context) {
    console.log("************************ init file *****************************");
    function fromDir(startPath,filter, rec, multiple){
      if (!fs.existsSync(startPath)){
          console.log("no dir ", startPath);
          return;
      }

      const files=fs.readdirSync(startPath);
      var resultFiles = []
      for(var i=0;i<files.length;i++){
          var filename=path.join(startPath,files[i]);
          var stat = fs.lstatSync(filename);
          if (stat.isDirectory() && rec){
              fromDir(filename,filter); //recurse
          }

          if (filename.indexOf(filter)>=0) {
              if (multiple) {
                  resultFiles.push(filename);
              } else {
                  return filename;
              }
          }
      }
      if(multiple) {
          return resultFiles;
      }
    }

    const xcodeProjPath = fromDir('platforms/ios','.xcodeproj', false);
    const projectPath = xcodeProjPath + '/project.pbxproj';
    const xcodeProj = xcode.project(projectPath);

    console.log('--------------------------------', xcodeProjPath);
    console.log(projectPath);

    xcodeProj.parseSync();
    xcodeProj.updateBuildProperty('ENABLE_BITCODE', 'NO');
    // unquote (remove trailing ")
    // Removing the char " at beginning and the end.
    var projectName = xcodeProj.getFirstTarget().firstTarget.name;

    if (projectName.substr(projectName.length - 1) == '"') {
        projectName = projectName.substr(1);
        projectName = projectName.substr(0, projectName.length - 1);
    }

    console.log('--------------------------------',projectName);
  var options = {
    shellPath: '/bin/sh', shellScript: `SETUP_SCRIPT=\${BUILT_PRODUCTS_DIR}/\${FRAMEWORKS_FOLDER_PATH}"/SquareInAppPaymentsSDK.framework/setup"
    if [ -f "$SETUP_SCRIPT" ]; then
      "$SETUP_SCRIPT"
    fi
    `, runOnlyForDeploymentPostprocessing: 0
  };
    console.log('options', options);
    console.log('--------------------------------', options);

    var buildPhase = xcodeProj.addBuildPhase([], 'PBXShellScriptBuildPhase', 'SquarePaySDKScript', xcodeProj.getFirstTarget().uuid, options).buildPhase;

    fs.chmod(projectPath, '0755', function(exc) {
        fs.writeFileSync(projectPath, xcodeProj.writeSync());
    });

    fs.writeFileSync(projectPath, xcodeProj.writeSync());
    console.log('Added Script build phase --------------------------------');

    var bridgingHeaderPath = path.join(context.opts.projectRoot, 'platforms', 'ios', projectName, 'Bridging-Header.h');
    console.log("------------",bridgingHeaderPath)
    var importStatement = '#import "AppDelegate.h"\n';

    fs.appendFileSync(bridgingHeaderPath, importStatement);
    console.log("header appended")
};

// Path to the build phase script
const buildPhaseScript = `
SETUP_SCRIPT=\${BUILT_PRODUCTS_DIR}/\${FRAMEWORKS_FOLDER_PATH}"/SquareInAppPaymentsSDK.framework/setup"
if [ -f "$SETUP_SCRIPT" ]; then
  "$SETUP_SCRIPT"
fi
`;
