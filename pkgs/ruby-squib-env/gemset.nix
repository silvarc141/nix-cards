{
  abbrev = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hj2qyx7rzpc7awhvqlm597x7qdxwi4kkml4aqnp5jylmsm4w6xd";
      type = "gem";
    };
    version = "0.1.2";
  };
  bigdecimal = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1p2szbr4jdvmwaaj2kxlbv1rp0m6ycbgfyp0kjkkkswmniv5y21r";
      type = "gem";
    };
    version = "3.2.2";
  };
  cairo = {
    dependencies = ["native-package-installer" "pkg-config" "red-colors"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02rd8zfzkq4nfv84y6jqmplc3ysygwladsnw1hfl44pgk9ync1ws";
      type = "gem";
    };
    version = "1.18.4";
  };
  cairo-gobject = {
    dependencies = ["cairo" "glib2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cc6id8s1xr8fchsnjccj7hbimm7pq6n9c1rr3rzf2wqxcx8k8fc";
      type = "gem";
    };
    version = "4.3.0";
  };
  classy_hash = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01b1zv6k47pxsrxqzfdvjhdlh51ldzw3drndnz8h09iklvvg6dhc";
      type = "gem";
    };
    version = "1.0.0";
  };
  csv = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gz7r2kazwwwyrwi95hbnhy54kwkfac5swh2gy5p5vw36fn38lbf";
      type = "gem";
    };
    version = "3.3.5";
  };
  fiddle = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vifygrkw22gcd4wzh8gc4pv6h1zpk6kll6mmprrf5174wvfxa3z";
      type = "gem";
    };
    version = "1.1.8";
  };
  game_icons = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dfnyfzr55l7sd9aa7r0jhy4fn7khjiiws97c0i0mfyacm0dsqw1";
      type = "gem";
    };
    version = "0.46.0.20221129";
  };
  gdk_pixbuf2 = {
    dependencies = ["gio2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bd88rf9drvkayap7vkqsmn2fhah7yy45acp72j7if3i5jlf3mf6";
      type = "gem";
    };
    version = "4.3.0";
  };
  gio2 = {
    dependencies = ["fiddle" "gobject-introspection"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x3yl2w1fyvbkh2l9z5ykgxhj46vd5jny8shvkxazavvn8rrmxp4";
      type = "gem";
    };
    version = "4.3.0";
  };
  glib2 = {
    dependencies = ["native-package-installer" "pkg-config"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bibrn7r68xy6anb5md1lbkzi5vmlnjhfq73zl9vfn616zqpn35k";
      type = "gem";
    };
    version = "4.3.0";
  };
  gobject-introspection = {
    dependencies = ["glib2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "072rzac8nlw2f601c49srirbvlgs1yx30f8a5ffc676ygiilfkw7";
      type = "gem";
    };
    version = "4.3.0";
  };
  highline = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1f8cr014j7mdqpdb9q17fp5vb5b8n1pswqaif91s3ylg5x3pygfn";
      type = "gem";
    };
    version = "2.1.0";
  };
  json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1861nwzxrfn7g90zmq9mndblprcqlfs1s0lyqp37wqdmip7g3gd4";
      type = "gem";
    };
    version = "2.13.0";
  };
  logger = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00q2zznygpbls8asz5knjvvj2brr3ghmqxgr83xnrdj4rk3xwvhr";
      type = "gem";
    };
    version = "1.7.0";
  };
  matrix = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nscas3a4mmrp1rc07cdjlbbpb2rydkindmbj3v3z5y1viyspmd0";
      type = "gem";
    };
    version = "0.4.3";
  };
  mercenary = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f2i827w4lmsizrxixsrv2ssa3gk1b7lmqh8brk8ijmdb551wnmj";
      type = "gem";
    };
    version = "0.4.0";
  };
  mini_magick = {
    dependencies = ["logger"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "194vlx50sj527zl9824m6kvwarcjb854vw63nh2f5szrj2f304vg";
      type = "gem";
    };
    version = "5.3.0";
  };
  mini_portile2 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12f2830x7pq3kj0v8nz0zjvaw02sv01bqs1zwdrc04704kwcgmqc";
      type = "gem";
    };
    version = "2.8.9";
  };
  native-package-installer = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bvr9q7qwbmg9jfg85r1i5l7d0yxlgp0l2jg62j921vm49mipd7v";
      type = "gem";
    };
    version = "1.1.9";
  };
  nokogiri = {
    dependencies = ["mini_portile2" "racc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0czsh9d738kj0bmpkjnczq9j924hg103gc00i0wfyg0fzn9psnmc";
      type = "gem";
    };
    version = "1.18.9";
  };
  pango = {
    dependencies = ["cairo-gobject" "gobject-introspection"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gr3ahxx4qm39p7lwylciimhy3idvgql9amfb27y681p4rj5zs8d";
      type = "gem";
    };
    version = "4.3.0";
  };
  pkg-config = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ddyqmc56r0vsgs9p17bb3v6q5j2xv51y95ad8p3mr60cm2006z0";
      type = "gem";
    };
    version = "1.6.2";
  };
  racc = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0byn0c9nkahsl93y9ln5bysq4j31q8xkf2ws42swighxd4lnjzsa";
      type = "gem";
    };
    version = "1.8.1";
  };
  rainbow = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      type = "gem";
    };
    version = "3.1.1";
  };
  red-colors = {
    dependencies = ["json" "matrix"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16lj0h6gzmc07xp5rhq5b7c1carajjzmyr27m96c99icg2hfnmi3";
      type = "gem";
    };
    version = "0.4.0";
  };
  roo = {
    dependencies = ["nokogiri" "rubyzip"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03p7ic7z7yw7mh4wg3pq7av1addxp5gq673j9gki1hgrap4kpd6b";
      type = "gem";
    };
    version = "2.10.1";
  };
  rsvg2 = {
    dependencies = ["cairo-gobject" "gdk_pixbuf2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b4bf5v6r1gyr2kndvqhayz9j7v8hrc6615g07z8xa1acnbgfryr";
      type = "gem";
    };
    version = "4.3.0";
  };
  ruby-progressbar = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
      type = "gem";
    };
    version = "1.13.0";
  };
  rubyzip = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05an0wz87vkmqwcwyh5rjiaavydfn5f4q1lixcsqkphzvj7chxw5";
      type = "gem";
    };
    version = "2.4.1";
  };
  squib = {
    dependencies = ["cairo" "classy_hash" "gio2" "gobject-introspection" "highline" "mercenary" "nokogiri" "pango" "rainbow" "roo" "rsvg2" "ruby-progressbar"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nnvpnh8zhf9ykjvl878swq6fjfnrgx5gp2yl0nnzbk1306d458p";
      type = "gem";
    };
    version = "0.19.0";
  };
}
