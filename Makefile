build:
	xcodebuild -project ShellJumper.xcodeproj -scheme ShellJumper -configuration Release build

format:
	swiftformat --swiftversion 6.2 .

stream:
	log stream --predicate 'subsystem == "com.huhu.ShellJumper"' --info --debug

