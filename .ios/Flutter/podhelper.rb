require 'fileutils'

def install_all_flutter_pods(flutter_application_path)
  install_flutter_engine_pod
  install_flutter_plugin_pods(flutter_application_path)
end

def install_flutter_engine_pod
  engine_dir = File.expand_path('engine', __dir__)
  pod 'Flutter', :path => engine_dir
end

def install_flutter_plugin_pods(flutter_application_path)
  plugin_pods_file = File.join(flutter_application_path, '.flutter-plugins-dependencies')
  return unless File.exist?(plugin_pods_file)

  plugin_pods = JSON.parse(File.read(plugin_pods_file))['plugins']['ios']
  plugin_pods.each do |plugin|
    pod plugin['name'], :path => File.join(flutter_application_path, '.pub-cache', 'hosted', 'pub.dev', plugin['name'])
  end
end
