// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	// CRITICAL for GitHub Pages deployment
	site: 'https://username.github.io',
	base: '/repository-name', // Replace with your actual repository name
	
	integrations: [
		starlight({
			title: 'Documentation',
			description: 'Professional documentation site built with Starlight',
			
			social: [
				{ icon: 'github', label: 'GitHub', href: 'https://github.com/username/repository-name' },
			],
			
			// Use autogenerate for better link handling
			sidebar: [
				{
					label: 'Getting Started',
					autogenerate: { directory: 'guides' },
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
				},
				{
					label: 'Best Practices',
					autogenerate: { directory: 'best-practices' },
				},
			],
			
			// Custom CSS if needed
			customCss: ['./src/styles/custom.css'],
		}),
	],
});
