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

namespace Daf.IoC.Adapters {

    public abstract class AbstractComponentAdapter : Object, IComponentAdapter  {

        public Value component_key { get; set; }
        public Type component_type { get; set; }
        public IContainer container { get; set; }

        construct {
            try {
                check_type_compatibility ();
                check_concrete ();
            } catch (Error e) {
                return;
            }
        }

        protected AbstractComponentAdapter (Value component_key, Type component_type) {
            Object (component_key : component_key, component_type : component_type);
        }

        public abstract Object? resolve_instance (IContainer? container = null);

        private void check_type_compatibility () throws RegistrationError {
            if (component_key.holds (typeof (Type))) {
                var key_type = component_key.get_gtype ();
                if (!key_type.is_a (component_type)) {
                    throw new RegistrationError.ASSIGNABILITY (key_type.name () + " " + component_type.name ());
                }
            }
        }

        protected void check_concrete () throws ComponentAdapterError {
            if (component_type.is_interface () || component_type.is_abstract () ||
                (!component_type.is_instantiatable ())) {
                 throw new ComponentAdapterError.NOT_CONCRETE_REGISTRATION ("Implementation is not Concrete class");
            }
        }

        public string to_string () {
            return  "[" + component_key.type_name () + "]";
        }
    }
}