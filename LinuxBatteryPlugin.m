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

#import "Plugin.h"

#define BAT_URL_STRING @"file:///sys/class/power_supply/"

/**
 * @brief A plugin for various battery related settings on Linux.
 */
@interface LinuxBatteryPlugin: OFPlugin <Plugin>
@end

@implementation LinuxBatteryPlugin
{
	OFMutableDictionary<OFString *, OFFile *> *_endThresholds;
}

- (OFString *)name
{
	return @"Linux battery plugin";
}

- (OFString *)version
{
	return @"0.1";
}

- (bool)shouldLoad
{
	OFFileManager *fileManager = OFFileManager.defaultManager;
	OFURL *batteriesURL = [OFURL URLWithString: BAT_URL_STRING];

	for (OFURL *candidate in
	    [fileManager contentsOfDirectoryAtURL: batteriesURL])
		if ([candidate.lastPathComponent hasPrefix: @"BAT"] &&
		    [fileManager directoryExistsAtURL: candidate])
			return true;

	return false;
}

- (void)prepareForPrivilegeDrop
{
	OFFileManager *fileManager = OFFileManager.defaultManager;
	OFURL *batteriesURL = [OFURL URLWithString: BAT_URL_STRING];

	_endThresholds = [OFMutableDictionary dictionary];

	for (OFURL *candidate in
	    [fileManager contentsOfDirectoryAtURL: batteriesURL]) {
		if (![candidate.lastPathComponent hasPrefix: @"BAT"])
			continue;

		if (![fileManager directoryExistsAtURL: candidate])
			continue;

		OFURL *endThresholdURL = [candidate URLByAppendingPathComponent:
		    @"charge_control_end_threshold"];
		OFFile *file;
		@try {
			file = [OFFile fileWithURL: endThresholdURL
					      mode: @"w+"];
		} @catch (OFOpenItemFailedException *e) {
			continue;
		}

		_endThresholds[candidate.lastPathComponent] = file;
	}
}
@end

id
init_plugin(void)
{
	return [[LinuxBatteryPlugin alloc] init];
}
