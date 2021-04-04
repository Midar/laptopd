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

#import <ObjFW/ObjFW.h>

#import "LaptopD.h"

/**
 * @brief Protocol shared by all plugins for laptopd.
 */
@protocol Plugin
/**
 * @brief The name of the plugin.
 */
@property (readonly, nonatomic) OFString *name;

/**
 * @brief The version of the plugin.
 *
 * Not meant for comparison, just to present to the user / logs.
 */
@property (readonly, nonatomic) OFString *version;

/**
 * @brief Whether the plugin should be loaded.
 *
 * If it returns false, the plugin is unloaded again. This is to determine if a
 * plugin is applicable for the system.
 */
@property (readonly, nonatomic) bool shouldLoad;

/**
 * @brief A map of devices handled by the plugin to the capabilities the plugin
 *	  can handle for them.
 */
@property (readonly, nonatomic)
    OFDictionary<OFString *, OFArray<capability_t> *> *devices;

/**
 * @brief This is called when the plugin should prepare for privileges being
 * dropped from root to an unprivileged user.
 *
 * The plugin should open all file descriptors etc. that it will need later
 * here. If an exception is thrown, the plugin will be unloaded and not used.
 */
- (void)prepareForPrivilegeDrop;
@end
