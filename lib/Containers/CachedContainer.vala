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
using Daf.IoC.Adapters;

namespace Daf.IoC.Containers {

    public class CachedContainer : Object, IContainer, IContainerRegistrar {

        public IContainer parent { get; set; }
        public ArrayList<IComponentAdapter> adapters { get; set; }
        public ArrayList instances {
            owned get { return resolves_of_type (typeof (Object)); }
            set {}
        }

        private IComponentAdapterFactory adapter_factory { get; private set; }

        private HashMap<string, IComponentAdapter> adapter_key_cache = new HashMap<string, IComponentAdapter> ();
        private ArrayList<IComponentAdapter> ordered_adapters = new ArrayList<IComponentAdapter> ();
        private HashMap<IContainer, IContainer> children = new HashMap<IContainer,IContainer> ();

        construct {
            adapters = new ArrayList<IComponentAdapter> ();
        }

        public CachedContainer (IComponentAdapterFactory? adapter_factory = null) {
            this.with_parent (null, adapter_factory);
        }

        public CachedContainer.with_parent (IContainer? parent = null,
                                    IComponentAdapterFactory? adapter_factory = null) {
            adapters = new ArrayList<IComponentAdapter> ();

            this.adapter_factory = adapter_factory != null ? adapter_factory : new DefaultComponentAdapterFactory () ;
            this.parent = parent;
        }

        public IComponentAdapter? get_adapter (Value component_key) {
            IComponentAdapter? adapter = null;

            try {
                adapter = (IComponentAdapter) adapter_key_cache.get (resolve_value_key (component_key));
            } catch (Error e) {
                //FIXME: handle exception...
                return null;
            }
            if (adapter == null && parent != null) {
                // Retrieve the Adapter from their parent.
                adapter = parent.get_adapter (component_key);
            }

            return adapter;
        }

        public IComponentAdapter? get_adapter_of_type (Type component_type)  throws ResolutionError {

            IComponentAdapter adapter_by_key = get_adapter (component_type);
            if (adapter_by_key != null) {
                return adapter_by_key;
            }

            ArrayList<IComponentAdapter> found = get_adapters_of_type (component_type);

            if (found.size == 1) {
                return (IComponentAdapter) found[0];
            }

            if (found.size == 0) {
                if (parent != null) {
                    return parent.get_adapter_of_type (component_type);
                } else {
                    return null;
                }
            } else {
                Value[] found_classes = new Value[found.size];
                for (int i = 0; i < found_classes.length; i++) {
                    IComponentAdapter adapter = (IComponentAdapter) found[i];
                    found_classes[i] = adapter.component_type;
                     throw new ResolutionError.AMBIGOUS_COMPONENT (component_type.name () + ((Type) found_classes[i]).name ());
                 }

           }
            return null;
        }

        public ArrayList? get_adapters_of_type (Type component_type) {

            ArrayList<IComponentAdapter> found = new ArrayList<IComponentAdapter> ();

            foreach (IComponentAdapter adapter in adapters)  {
                debug ("adapter of type %s: .... %s", adapter.component_type.name(),component_type.name ());
                if (adapter.component_type.is_a (component_type)) {
                    debug ("Adapter added :%s %s", adapter.component_type.name(),component_type.name ());
                    found.add (adapter);
                   } else {
                   debug ("Adapter not added");
                }
            }
            return found;
        }


        public IComponentAdapter? unregister_key (Value component_key) {
            string? str_key = null;

            try {
                str_key = resolve_value_key (component_key);
            } catch (Error e) {
                //FIXME: handle exception...
                return null;
            }

            var adapter = (IComponentAdapter) adapter_key_cache.get (str_key);

            if (adapter != null) {
                adapter_key_cache.unset (str_key);
                adapters.remove (adapter);
                ordered_adapters.remove (adapter);
            }

            return adapter;
        }

        public IComponentAdapter register_instance (Object instance) throws RegistrationError {

            if (instance == this) {
                throw new RegistrationError.ASSIGNABILITY (
                      "Cannot register a container to itself!"
                  );
            }

            Type instance_key = instance.get_type ();

            IComponentAdapter adapter = new InstanceComponentAdapter (instance_key, instance);

            register_adapter (adapter);

            return adapter;
        }

        public IComponentAdapter register_key (Value component_key,
                                           Type? component_type = null,
                                           Parameter[]? parameters = null)
            requires (component_key.holds (typeof (Type)) ||
                   (component_key.holds (typeof (string)) && component_type != null)) {

            if (component_type == null) {
                component_type = component_key.get_gtype ();
            }

            IComponentAdapter adapter = adapter_factory.create_adapter (component_key, component_type, parameters);
            try {
                    register_adapter (adapter);
            } catch (Error e) {
                //FIXME: handle exception...
                return adapter;
            }

            return adapter;
        }

        public IComponentAdapter register_adapter (IComponentAdapter adapter) throws RegistrationError {
            
            string? str_key = null;
            
            try {
                str_key = resolve_value_key (adapter.component_key);
            } catch (Error e) {
                //FIXME: handle exception...
            }

            if (adapter_key_cache.has_key (str_key)) {
                debug ("STR_KEY: %s", str_key);
                   throw new RegistrationError.DUPLICATE_KEY (str_key);
            }
            adapter.container = this;
            adapters.add (adapter);
            adapter_key_cache.set (str_key, adapter);

            return adapter;
        }

        public void add_ordered_adapter (IComponentAdapter adapter) {
            debug ("Add ordered comp");
            
            if (!ordered_adapters.contains (adapter)) {
                ordered_adapters.add (adapter);
            }
            debug ("Added to ordered comp");
        }

        public Object? resolve (Value component_key) {
            // Retrieve or create an adapter.
            IComponentAdapter adapter = get_adapter (component_key);

            if (adapter != null) {
                return adapter.resolve_instance ();
            }  else {
                return null;
            }
        }

        public ArrayList resolves_of_type (Type? component_type) {
            if (component_type == null) {
                return new ArrayList<Object> ();
            }

            var adapter_to_instance_map = new HashMap<IComponentAdapter, Object> ();
            foreach (IComponentAdapter adapter in adapters) {
                if (component_type.is_a (adapter.component_type)) {
                    Object instance = adapter.resolve_instance ();
                    adapter_to_instance_map.set (adapter, instance);


                    add_ordered_adapter (adapter);
                }
            }

            var result = new ArrayList<Object> ();
            foreach (IComponentAdapter adapter in ordered_adapters) {
                Object instance = adapter_to_instance_map[adapter];
                if (instance != null) {
                    result.add (instance);
                }
            }

            return result;
        }

        public Object? resolve_of_type (Type component_type) {
            IComponentAdapter? adapter = null;

            try {
                adapter = get_adapter_of_type (component_type);
            } catch (Error e) {
                //FIXME: handle exception...
            }

            if (adapter == null) {
                return null;
            } else {
                return adapter.resolve_instance ();
            }

        }

        public IComponentAdapter? unregister_instance (Object instance) {
            foreach (IComponentAdapter adapter in adapters) {
                if (adapter.resolve_instance () == instance) {
                    return unregister_key (adapter.component_key);
                }
            }
            return null;
        }

        public IContainerRegistrar make_child_container () {
            IContainerRegistrar pc = new CachedContainer.with_parent (this, adapter_factory);
            add_child_container (pc);
            return pc;
        }

        public virtual bool add_child_container (IContainer child)   {
            if (children.has_key (child))   {
                return false;
            }
            children.set (child, child);
            return true;
        }

        public virtual bool remove_child_container (IContainer child)  {
            if (children.has_key (child)) {
                children.unset (child);
                return true;
            }

            return false;
        }

        public static ArrayList order_adapters_with_container_adapters_last (ArrayList adapters) {
            var result = new ArrayList <IComponentAdapter> ();
            var containers = new ArrayList <IComponentAdapter> ();

             foreach (IComponentAdapter adapter in (GLib.List<IComponentAdapter>) adapters)  {

                if (typeof (IContainer).is_a (adapter.component_type)) {
                    containers.add (adapter);
                }  else  {
                    result.add (adapter);
                }
            }
            result.add_all (containers);
            return result;
        }

        internal string resolve_value_key (Value value_key) throws ResolutionError {
            string result = "";

            if (value_key.holds (typeof (string))) {
                result = (string) value_key;
            } else if (value_key.holds (typeof (Type))) {
                result = ((Type) value_key).name ();
            } else {
                throw new ResolutionError.NOT_VALID_KEY_TYPE (value_key.type ().name ());
            }

            return result;

        }
    }
}
