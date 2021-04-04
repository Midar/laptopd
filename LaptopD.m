/*
 * laptopd - a daemon to control various aspects of laptop computers.
 * Copyright (C) 2021 Jonathan Schleifer <js@nil.im>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <grp.h>
#include <pwd.h>
#include <unistd.h>

#import <ObjFW/ObjFW.h>

#import "Plugin.h"

@interface LaptopD: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(LaptopD)

@implementation LaptopD
- (void)applicationDidFinishLaunching
{
	OFString *modulesDir =
	    [@LIBDIR stringByAppendingPathComponent: @"laptopd"];
	OFFileManager *fileManager = OFFileManager.defaultManager;
	OFMutableArray<OFPlugin <Plugin> *> *plugins = [OFMutableArray array];

	for (OFString *module in
	    [fileManager contentsOfDirectoryAtPath: modulesDir]) {
		void *pool = objc_autoreleasePoolPush();
		OFString *pluginPath = [OFString pathWithComponents:
		    @[ modulesDir, module, module ]];
		OFPlugin <Plugin> *plugin =
		    [OFPlugin pluginWithPath: pluginPath];

		if (plugin.shouldLoad) {
			of_log(@"Loaded %@ %@", plugin.name, plugin.version);
			[plugins addObject: plugin];
		}

		objc_autoreleasePoolPop(pool);
	}

	of_log(@"%zu plugin(s) loaded", plugins.count);

	of_log(@"Preparing to drop privileges");
	OFMutableArray <OFPlugin <Plugin> *> *pluginsToDrop =
	    [OFMutableArray array];
	for (OFPlugin <Plugin> *plugin in plugins) {
		@try {
			[plugin prepareForPrivilegeDrop];
		} @catch (id e) {
			of_log(@"%@ %@ failed to prepare for privilege drop, "
			    @"removing...", plugin.name, plugin.version);
			[pluginsToDrop addObject: plugin];
		}
	}
	for (OFPlugin <Plugin> *plugin in pluginsToDrop)
		[plugins removeObjectIdenticalTo: plugin];
	[pluginsToDrop removeAllObjects];
	pluginsToDrop = nil;

	/* FIXME: Make arguments */
	struct passwd *passwd = getpwnam("nobody");
	struct group *group = getgrnam("nobody");
	if (setgid(group->gr_gid) != 0) {
		of_log(@"setgid() failed: %s", strerror(errno));
		[OFApplication terminateWithStatus: 1];
	}
	if (setuid(passwd->pw_uid) != 0) {
		of_log(@"setuid() failed: %s", strerror(errno));
		[OFApplication terminateWithStatus: 1];
	}

	of_log(@"Privileges dropped");
}
@end
