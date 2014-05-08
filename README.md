# RPMs needed for NGINX

* nginx with auth module

### nginx
Information for [creating a build environment](http://fedoraproject.org/wiki/How_to_create_an_RPM_package) for RPM builds

Custom nginx build with auth module

### HOWTO
-----

First you have to download and unpack a fitting SRPM. We can get one directly from nginx.org: http://nginx.org/packages/centos/6/SRPMS/

    # rpm -Uvh http://nginx.org/packages/centos/6/SRPMS/nginx-1.6.0-1.el6.ngx.src.rpm

RPMs should never be build as root, so you should create a new user and move the RPM sources into its home directory.

    # useradd -m builder
    # mv /root/rpmbuild /home/builder/ && chown -R builder. /home/builder/rpmbuild

Now you have to update the two ./configure statements in the spec file.

	%build
	./configure \
Just add them between the other with entries.

	--with-http_auth_request_module \

You can now build the RPM.

    $ rpmbuild -ba ~/rpmbuild/SPECS/nginx.spec

The RPM is saved under ~/rpmbuild/RPMS/
