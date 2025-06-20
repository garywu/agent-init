// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	// CRITICAL for GitHub Pages deployment
	site: 'https://garywu.github.io',
	base: '/claude-init', // Matches the repository name
	
	integrations: [
		starlight({
			title: 'Agent Init',
			description: 'Professional development standards and workflows for AI-assisted projects',
			
			social: [
				{ icon: 'github', label: 'GitHub', href: 'https://github.com/garywu/claude-init' },
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
