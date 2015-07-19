<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Simple WordPress Vagrant</title>
	<style>
		body {
			font-family: sans-serif;
			max-width: 50em;
			padding: 1em;
			margin: 0 auto;
			font-size: 1.25em;
		}

		code {
			padding: .2em;
			background: rgba(0,0,0,0.1);
			border-radius: 2px;
		}
	</style>
</head>
<body>
	<h1>Simple WordPress Vagrant</h1>
	<p>For usage see the
		<a href="https://github.com/torrottum/simple-wp-vagrant/blob/master/README.md">README</a>
		or take a look at the <code>www/example</code> folder</p>

	<h2>Sites:</h2>
	<ul>
		<?php
			$hostsFiles = glob(__DIR__ . '/../*/hosts');
			foreach ($hostsFiles as $hostsFile) {
				$hostsFile = file_get_contents($hostsFile);
				foreach (explode("\n", $hostsFile) as $host) {
					if (empty($host))
						continue;

					echo sprintf('<li><a href="http://%s">%1$s</a></li>', $host);
				}
			}
		?>
	</ul>
</body>
</html>
