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
using Daf.IoC;
using Gee;
namespace Daf.IoC.Adapters {

    public abstract class InstantiatingComponentAdapter : AbstractComponentAdapter {
        public Parameter[]? parameters { get; set; }

        public InstantiatingComponentAdapter (Value key, Type type, Parameter[]? parameters = null) {
            base (key, type);
            this.parameters = parameters;
        }

        public override Object? resolve_instance (IContainer? container = null) {
            ArrayList<IComponentAdapter> ordered_list = new ArrayList<IComponentAdapter> ();

            Object? instance = null;
            try {
                instance = instantiate (ref ordered_list);
            } catch (Error e) {
                //FIXME: handle exception...
                return instance;
            }

            foreach (var dependency_adapter in ordered_list) {
                debug ("Adapter added: %s", dependency_adapter.component_type.name());
                this.container.add_ordered_adapter (dependency_adapter);
            }

            return instance;
        }

        public abstract Object? instantiate (ref ArrayList<IComponentAdapter> ordered_list) throws DependencyError;
    }
}