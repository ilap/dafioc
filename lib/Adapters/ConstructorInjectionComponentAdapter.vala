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
using Gee;
using Daf.IoC;

namespace Daf.IoC.Adapters {

    public class ConstructorInjectionComponentAdapter : InstantiatingComponentAdapter {
        protected bool instantiating = false;

        public ConstructorInjectionComponentAdapter (Value component_key, Type component_type,
                                                    Parameter[]? parameters = null) {
            base (component_key, component_type, parameters);
        }

        private Parameter[]? build_constructor_parameters (ref ArrayList<IComponentAdapter> ordered_list) throws DependencyError {
            bool failed = false;
            var dependencies = new ArrayList<IComponentAdapter> ();
            ParamSpec[]? param_specs = get_construct_properties ();
            Parameter[]?  parameters = {};

            if (param_specs != null) {
                foreach (ParamSpec param_spec in param_specs) {

                    IComponentAdapter? adapter = null;
                    try {
                        adapter = container.get_adapter_of_type (param_spec.value_type);
                    } catch (Error e) {
                        //FIXME: handle exception...
                    }

                    if (adapter == null | adapter == this || component_key == adapter.component_key) {
                        failed = true;
                        throw new DependencyError.UNSATISFIED_DEPENDENCY ("Build Constructor parameters...");
                    } else {

                        Value object = adapter.resolve_instance ();
                        Parameter param = Parameter ();

                        param.value = object;
                        param.name = param_spec.name;

                        parameters += param;

                        dependencies.add (adapter);
                    }
                }

                if (failed) {
                    ordered_list.clear ();
                } else {
                    ordered_list.add_all (dependencies);
                }
            }
            debug ("Parameter's length :%d", parameters.length);
            return parameters.length == 0 ? null : parameters;
        }

        public override Object? instantiate  (ref ArrayList<IComponentAdapter> ordered_list) throws DependencyError {

            Object? result = null;
            lock (instantiating) {
                if (instantiating) {
                    throw new DependencyError.CYCLIC_DEPENDENCY ("Cyclic Dependency");
                }
                instantiating = true;

                var parameters = build_constructor_parameters (ref ordered_list);

                if (parameters == null) {

                    debug ("Creating single...: %s", component_type.name ());
                    result = Object.new (component_type);
                } else {
                    debug ("Instantiating: %s", component_type.name ());

                    // Dirty hacking of Type transformation
                    Object o = parameters[0].value.get_object ();
                    Value object_holder = Value (o.get_type ());
                    object_holder.set_object (o);

                       parameters[0].value = object_holder;
                       result = Object.newv (component_type, parameters);
                }

                debug ("Instantiating...");
                instantiating = false;
            }
            return result;
        }

        public  ParamSpec[]? get_construct_properties () {

            ObjectClass obc = (ObjectClass) component_type.class_ref ();
            ParamSpec[] construct_properties = {};
            var properties = obc.list_properties ();

            foreach (var property in properties) {
                int flag = property.flags  & (ParamFlags.CONSTRUCT);// | ParamFlags.CONSTRUCT_ONLY);
                // debug ("FLAGS %d", flag);
                if (flag != 0) {
                    debug ("I got a Costructor parameter (%s): %s %s", obc.get_type (). name (), property.value_type.name (), property.get_name ());
                    construct_properties += property;
                    // Parameter () { name = property.get_name (), value = "null " + property.get_name () };
                }
            }

           return construct_properties.length == 0 ? null : construct_properties;
        }
    }
}