/***
 * Copyright (c) 2012 Pal Dorogi <pal.dorogi@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 ***/
namespace Daf.IoC.Adapters {

    public class CachingComponentAdapter : DecoratingComponentAdapter {
        public Object? cached_instance { private get; construct set; }

        public CachingComponentAdapter (IComponentAdapter subject, Object? cached_instance = null) {
            Object (subject : subject, cached_instance : cached_instance);
        }

        public override Object? resolve_instance (IContainer? container = null) {
            if (cached_instance == null) {
                cached_instance = base.resolve_instance (container);
            }
            return cached_instance;
        }
    }
}