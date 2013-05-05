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

    public class DefaultComponentAdapterFactory : Object, IComponentAdapterFactory {

        public IComponentAdapter create_adapter (Value component_key,
                                                   Type? component_type = null,
                                                Parameter[]? parameters = null) {

            var cica = new ConstructorInjectionComponentAdapter (component_key, 
                                                                    component_type, 
                                                                    parameters);
            return new CachingComponentAdapter (cica);
        }

    }
}