/**
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
 **/
using Gee;

namespace Daf.IoC {

    public interface IContainer : Object {

        public abstract IContainer parent { get; set; }
        public abstract ArrayList<IComponentAdapter> adapters { get; set; }
        public abstract ArrayList instances { owned get; set; }

        public abstract Object? resolve (Value key);
        public abstract Object? resolve_of_type (Type type);

        public abstract ArrayList resolves_of_type (Type? type);

        public abstract IComponentAdapter? get_adapter (Value key);
        public abstract IComponentAdapter? get_adapter_of_type (Type type) throws ResolutionError;

        public abstract ArrayList? get_adapters_of_type (Type type);

        public abstract void add_ordered_adapter (IComponentAdapter adapter);
    }
}