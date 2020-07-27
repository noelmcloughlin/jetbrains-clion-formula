# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import clion with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

{%- if clion.linux.install_desktop_file %}
    {%- if clion.pkg.use_upstream_macapp %}
        {%- set sls_package_install = tplroot ~ '.macapp.install' %}
    {%- else %}
        {%- set sls_package_install = tplroot ~ '.archive.install' %}
    {%- endif %}

include:
  - {{ sls_package_install }}

clion-config-file-file-managed-desktop-shortcut_file:
  file.managed:
    - name: {{ clion.linux.desktop_file }}
    - source: {{ files_switch(['shortcut.desktop.jinja'],
                              lookup='clion-config-file-file-managed-desktop-shortcut_file'
                 )
              }}
    - mode: 644
    - user: {{ clion.identity.user }}
    - makedirs: True
    - template: jinja
    - context:
      command: {{ clion.command|json }}
                        {%- if grains.os == 'MacOS' %}
      edition: {{ '' if 'edition' not in clion else clion.edition|json }}
      appname: {{ clion.dir.path }}/{{ clion.pkg.name }}
                        {%- else %}
      edition: ''
      appname: {{ clion.dir.path }}
    - onlyif: test -f "{{ clion.dir.path }}/{{ clion.command }}"
                        {%- endif %}
    - require:
      - sls: {{ sls_package_install }}

{%- endif %}
