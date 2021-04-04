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

#define WMI_PATH @"/sys/devices/platform/asus-nb-wmi"

/**
 * @brief A plugin for various ASUS laptops.
 *
 * For now, this is specific to the ASUS ROG Zephyrus G14 (2021), as this is
 * the laptop the author has. If people offer to test laptopd with the
 * ASUSPlugin on their laptop, the author is happy to add support for them.
 */
@interface ASUSLinuxPlugin: OFPlugin <Plugin>
@end

@implementation ASUSLinuxPlugin
{
	OFFile *_thermalThrottlePolicy, *_dGPUYeet;
}

- (OFString *)name
{
	return @"ASUS laptop Linux plugin";
}

- (OFString *)version
{
	return @"0.1";
}

- (bool)shouldLoad
{
	return [OFFileManager.defaultManager directoryExistsAtPath: WMI_PATH];
}

- (OFDictionary<OFString *, OFArray<capability_t> *> *)devices
{
	OFMutableArray *capabilities = [OFMutableArray array];

	if (_thermalThrottlePolicy != nil)
		[capabilities addObject: @"fan_control"];
	if (_dGPUYeet != nil)
		[capabilities addObject: @"dgpu_switching"];

	return @{ @"asus-nb-wmi": capabilities };
}

- (void)prepareForPrivilegeDrop
{
	OFString *thermalThrottlePolicyPath = [WMI_PATH
	    stringByAppendingPathComponent: @"throttle_thermal_policy"];
	OFString *dGPUYeetPath = [WMI_PATH
	    stringByAppendingPathComponent: @"dgpu_yeet"];

	_thermalThrottlePolicy = [OFFile
	    fileWithPath: thermalThrottlePolicyPath
		    mode: @"w+"];
	@try {
		_dGPUYeet = [OFFile fileWithPath: dGPUYeetPath mode: @"w+"];
	} @catch (OFOpenItemFailedException *e) {
		/*
		 * This is an experimental kernel patch that is unlikely to
		 * exist on many systems, so just ignore.
		 */
	}
}
@end

id
init_plugin(void)
{
	return [[ASUSLinuxPlugin alloc] init];
}
