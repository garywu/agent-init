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
					items: [
						{ label: 'Getting Started', slug: 'guides/getting-started' },
						{ label: 'Project Structure', slug: 'reference/project-structure' },
					],
				},
				{
					label: 'Workflow',
					autogenerate: { directory: 'guides/workflow' },
				},
				{
					label: 'Development',
					autogenerate: { directory: 'guides/development' },
				},
				{
					label: 'Tools',
					autogenerate: { directory: 'guides/tools' },
				},
				{
					label: 'Security',
					autogenerate: { directory: 'guides/security' },
				},
				{
					label: 'Deployment',
					autogenerate: { directory: 'guides/deployment' },
				},
				{
					label: 'Documentation',
					autogenerate: { directory: 'guides/documentation' },
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
				},
			],
			
			// Custom CSS if needed
			customCss: ['./src/styles/custom.css'],
		}),
	],
});
