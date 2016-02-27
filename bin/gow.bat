@if (true == false) @end /*!
cscript //nologo //e:javascript "%~dpnx0" %*
@goto :EOF */

// ------------------------------------------------------------------------
//
// Gow - The lightweight alternative to Cygwin
// Handles all tasks for the Gow project.  
// Author: Brent R. Matzelle
//
// ------------------------------------------------------------------------

var PROGNAME = 'Gow';
var VERSION = '0.8.0 Portable';

function showHelp()
{
/*!
PROGNAME VERSION - The lightweight alternative to Cygwin
Usage: gow OPTION

Options:
    -l, --list                       Lists all executables
    -V, --version                    Prints the version
    -h, --help                       Show this message
*/
	var helpMsg = arguments.callee.toString()
		.replace(/[\s\S]*\/\*\!\s*/m, '')
		.replace(/\s*\*\/[\s\S]*/m, '')
		.replace(/PROGNAME/, PROGNAME)
		.replace(/VERSION/, VERSION)
		;
	print(helpMsg);
};

function showVersion()
{
	print(PROGNAME + ' ' + VERSION);
};

function main()
{
	if ( ! WScript.Arguments.length ) {
		showHelp();
		return;
	}

	var opt = WScript.Arguments.item(0);

	switch ( opt ) {
	case '-l':
	case '--list':
		showList();
		break;
	case '-V':
	case '--version':
		showVersion();
		break;
	case '-h':
	case '--help':
		showHelp();
		break;
	default:
		print('UNKNOWN COMMAND: [' + opt + ']\n');
		showHelp();
		break;
	}
};

// ------------------------------------------------------------------------

function print(message)
{
	WScript.Echo(message || '');
};

function dirname(filename)
{
	return String(filename).replace(/\\[^\\]*$/, '');
};

function basename(filename)
{
	return String(filename).replace(/.*\\/, '').replace(/\..+?$/, '');
};

function isExecutable(filename)
{
	return /\.(exe|bat)$/i.test(filename);
};

function getList()
{
	var script_path = dirname(WScript.ScriptFullName);

	var fso = new ActiveXObject('Scripting.FileSystemObject');
	var folder = fso.GetFolder(script_path);

	var fileList = [];

	var e = new Enumerator(folder.Files);
	for ( ; ! e.atEnd(); e.moveNext() ) {
		var filename = e.item();
		if ( ! isExecutable(filename) ) {
			continue;
		}
		fileList.push(basename(filename));
	}

	return fileList;
};

function showList()
{
	var list = getList();

	var delim = ' ';
	var delimLen = delim.length;

	var len = 0;
	var limit = 78;

	for (var i = 0; i < list.length; i++) {
		if ( ( len + list[i].length + delimLen ) / limit >= 1 ) {
			list[i] = '\n' + list[i];
			len = 0;
		}
		len += list[i].length + delimLen;
	}

	print('Available executables:\n');
	//print(new Array(limit + 1).join('-'));
	print(list.join(delim));
};

// ------------------------------------------------------------------------

main();

// ------------------------------------------------------------------------

// EOF
