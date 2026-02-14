import React from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';

const ASCII_ART = `  ██╗ ██████╗ ███╗   ██╗██╗████████╗██╗ ██████╗ ███╗   ██╗
  ██║██╔════╝ ████╗  ██║██║╚══██╔══╝██║██╔═══██╗████╗  ██║
  ██║██║  ███╗██╔██╗ ██║██║   ██║   ██║██║   ██║██╔██╗ ██║
  ██║██║   ██║██║╚██╗██║██║   ██║   ██║██║   ██║██║╚██╗██║
  ██║╚██████╔╝██║ ╚████║██║   ██║   ██║╚██████╔╝██║ ╚████║
  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
               ███╗   ██╗██╗   ██╗██╗███╗   ███╗
               ████╗  ██║██║   ██║██║████╗ ████║
               ██╔██╗ ██║██║   ██║██║██╔████╔██║
               ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
               ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
               ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝`;

const features = [
  {
    title: '$ decode',
    description:
      'Extract embedded Python scripts from Ignition JSON files into virtual buffers with full syntax highlighting.',
  },
  {
    title: '$ complete',
    description:
      'LSP completions for system.tag, system.db, system.perspective, and 200+ Ignition API functions.',
  },
  {
    title: '$ hover',
    description:
      'Inline documentation with parameter types, return values, and scope info for every system.* call.',
  },
  {
    title: '$ diagnose',
    description:
      'Catch unknown functions, wrong argument counts, and scope violations before deploying to the gateway.',
  },
  {
    title: '$ kindling',
    description:
      'Open .gwbk gateway backup files directly from Neovim with automatic Kindling detection.',
  },
  {
    title: '$ detect',
    description:
      'Automatic filetype recognition for Ignition projects by extension, filename, path, and content markers.',
  },
];

export default function Home(): React.JSX.Element {
  return (
    <Layout
      title="Neovim plugin for Ignition SCADA"
      description="LSP completions, script decode/encode, and gateway backup support for Ignition development in Neovim"
    >
      {/* ASCII Hero */}
      <section className="hero-ascii">
        <pre>{ASCII_ART}</pre>
        <div className="hero-tagline">
          {'> ignition development, from your terminal'}
          <span className="cursor" />
        </div>
      </section>

      {/* Features */}
      <section className="features-section">
        <div className="features-grid">
          {features.map((feature) => (
            <div key={feature.title} className="feature-card">
              <h3>{feature.title}</h3>
              <p>{feature.description}</p>
            </div>
          ))}
        </div>
      </section>

      {/* CTA */}
      <section className="cta-section">
        <div className="cta-terminal">
          <div className="terminal-header">
            <span className="terminal-dot red" />
            <span className="terminal-dot yellow" />
            <span className="terminal-dot green" />
          </div>
          <code>
            <span className="comment">-- lazy.nvim</span>
            {'\n'}
            <span className="prompt">{'{'}</span> <span className="string">'TheThoughtagen/ignition-nvim'</span> <span className="prompt">{'}'}</span>
            {'\n\n'}
            <span className="comment">-- open an ignition file and decode</span>
            {'\n'}
            <span className="prompt">:</span>IgnitionDecode
            {'\n\n'}
            <span className="comment">-- edit with full LSP support, then save</span>
            {'\n'}
            <span className="prompt">:</span>w
          </code>
        </div>
        <div className="cta-buttons">
          <Link className="primary" to="/docs/getting-started/installation">
            Get Started
          </Link>
          <Link
            className="secondary"
            href="https://github.com/TheThoughtagen/ignition-nvim"
          >
            View on GitHub
          </Link>
        </div>
      </section>
    </Layout>
  );
}
