pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string password: ''
    property bool showPopup: false
    property string authError: ''

    property var _pendingCommand: null
    property var _pendingCallback: null
    property var _pendingPersistentCommand: null

    function run(command, callback) {
        console.log(`sudo run, cached password: ${root.password !== ''}`);
        if (root.password !== '') {
            execute(command, callback);
        } else {
            root._pendingCommand = command;
            root._pendingCallback = callback || null;
            root.authError = '';
            root.showPopup = true;
        }
    }

    function runPersistent(command) {
        console.log(`sudo run persistent, cached password: ${root.password !== ''}`);
        if (root.password !== '') {
            startPersistentRunner(command);
        } else {
            root._pendingPersistentCommand = command;
            root.authError = '';
            root.showPopup = true;
        }
    }

    function stopPersistent() {
        persistentRunner.running = false;
    }

    function submitPassword(pwd) {
        root.password = pwd;
        root.authError = '';
        root.showPopup = false;
        validator.running = true;
    }

    function cancel() {
        root.showPopup = false;
        root.authError = '';
        var cb = root._pendingCallback;
        root._pendingCommand = null;
        root._pendingCallback = null;
        root._pendingPersistentCommand = null;
        if (cb)
            cb(false);
    }

    function execute(command, callback) {
        console.log(`sudo execute: ${command.join(' ')}`);
        runner.command = ['sudo', '-S'].concat(command);
        runner.callback = callback || null;
        runner.running = true;
    }

    function startPersistentRunner(command) {
        console.log(`sudo start persistent: ${command.join(' ')}`);
        persistentRunner.command = ['sudo', '-S'].concat(command);
        persistentRunner.running = true;
    }

    Process {
        id: validator
        running: false
        stdinEnabled: true
        command: ['sudo', '-S', '-v']

        onStarted: {
            validator.write(root.password + '\n');
        }

        onExited: (code) => {
            validatorTimeout.stop();
            if (code === 0) {
                var cmd = root._pendingCommand;
                var cb = root._pendingCallback;
                root._pendingCommand = null;
                root._pendingCallback = null;
                if (cmd)
                    execute(cmd, cb);
                var pcmd = root._pendingPersistentCommand;
                root._pendingPersistentCommand = null;
                if (pcmd)
                    startPersistentRunner(pcmd);
            } else {
                root._pendingCommand = null;
                root._pendingCallback = null;
                root._pendingPersistentCommand = null;
                root.password = '';
                root.authError = 'Incorrect password. Try again.';
                root.showPopup = true;
            }
        }

        onRunningChanged: {
            if (validator.running)
                validatorTimeout.running = true;
        }

        stderr: StdioCollector {
            onStreamFinished: {
                console.log('sudo validate:', this.text);
            }
        }
    }

    Timer {
        id: validatorTimeout
        interval: 5000
        repeat: false
        onTriggered: {
            validator.running = false;
            root.password = '';
            root.authError = 'Authentication timed out. Try again.';
            root.showPopup = true;
        }
    }

    Process {
        id: runner
        running: false
        stdinEnabled: true
        property var callback: null

        onStarted: {
            runner.write(root.password + '\n');
        }

        onExited: (code) => {
            runnerTimeout.stop();
            console.log(`sudo runner exited: ${code}`);
            var success = (code === 0);
            if (!success) {
                root.password = '';
                root.authError = 'Command failed. Re-enter password.';
            }
            if (runner.callback) {
                runner.callback(success);
                runner.callback = null;
            }
            if (!success)
                root.showPopup = true;
        }

        onRunningChanged: {
            if (runner.running)
                runnerTimeout.running = true;
        }

        stdout: StdioCollector {
            onStreamFinished: {
                console.log('sudo out:', this.text);
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                console.log('sudo err:', this.text);
            }
        }
    }

    Timer {
        id: runnerTimeout
        interval: 15000
        repeat: false
        onTriggered: {
            runner.running = false;
            root.password = '';
            root.authError = 'Command timed out.';
            root.showPopup = true;
            if (runner.callback) {
                runner.callback(false);
                runner.callback = null;
            }
        }
    }

    Process {
        id: persistentRunner
        running: false
        stdinEnabled: true

        onStarted: {
            persistentRunner.write(root.password + '\n');
        }

        onExited: (code) => {
            console.log(`sudo persistent exited: ${code}`);
        }

        stdout: StdioCollector {
            onStreamFinished: {
                console.log('sudo persistent out:', this.text);
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                console.log('sudo persistent err:', this.text);
            }
        }
    }
}
