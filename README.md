# RPMs needed for NGINX

* lua-cjson
* nginx mit lua modul

### lua-cjson Bauanleitung
[Bauanleitung des rpms](http://www.kyne.com.au/~mark/software/lua-cjson-manual.html#_rpm)


### nginx
Zusatz infos zum [Aufsetzen der Umgebung](http://fedoraproject.org/wiki/How_to_create_an_RPM_package) für RPM builds

Custom nginx build with HttpLuaModule

### HOWTO
-----

First you have to download and unpack a fitting SRPM. We can get one directly from nginx.org: http://nginx.org/packages/centos/6/SRPMS/

    # rpm -Uvh http://nginx.org/packages/centos/6/SRPMS/nginx-1.4.2-1.el6.ngx.src.rpm

RPMs should never be build as root, so you should create a new user and move the RPM sources into its home directory.

    # useradd -m builder
    # mv /root/rpmbuild /home/builder/ && chown -R builder. /home/builder/rpmbuild

Now you have to switch to the new user and download all modules you want to compile into nginx into ~/rpmbuild/SOURCES/

    # su - rpmbuilder
    $ cd ~/rpmbuild/SOURCES
    $ wget -O ngx_devel_kit.tar.gz https://github.com/simpl/ngx_devel_kit/archive/v0.2.18.tar.gz
    $ wget -O lua-nginx-module.tar.gz https://github.com/chaoslawful/lua-nginx-module/archive/v0.8.5.tar.gz

Grab the newest sources here:

*   [nginx devel kit](https://github.com/simpl/ngx_devel_kit/tags)
*   [nginx lua module](https://github.com/chaoslawful/lua-nginx-module/tags)

Next you have to edit the file ~/rpmbuild/SPECS/nginx.spec. First find the section with all the "Source" entries (Source1, Source2, etc.). Add the two tarballs to that list.

    [..]
    Source7: nginx.suse.init
    Source8: ngx_devel_kit.tar.gz
    Source9: lua-nginx-module.tar.gz

Then search for the section

    %prep
    %setup -q

and add the following lines:

    %{__tar} zxvf %{SOURCE8}
    %setup -T -D -a 8
    %{__tar} zxvf %{SOURCE9}
    %setup -T -D -a 9

Afterwards you have to update the two ./configure statements in the spec file. Just add them as the last parameters.

    ./configure \
        [..]
        --add-module=%{_builddir}/%{name}-%{version}/ngx_devel_kit \
        --add-module=%{_builddir}/%{name}-%{version}/lua-nginx-module \
        $*

Check how the base directory is called when you unpack the tarballs. Github tends to use generic names inside the archives.

You can now build the RPM.

    $ rpmbuild -ba ~/rpmbuild/SPECS/nginx.spec

The RPM is saved under ~/rpmbuild/RPMS/
