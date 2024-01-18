import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Easy to Use',
    Svg: require('@site/static/img/undraw_docusaurus_mountain.svg').default,
    description: (
      <>
        Touying provides two different ways to compose slides, based on headings and based on slide blocks.
        You can choose the style you prefer, simple yet powerful.
      </>
    ),
  },
  {
    title: 'Dynamic Slides',
    Svg: require('@site/static/img/undraw_docusaurus_tree.svg').default,
    description: (
      <>
        Touying offers markers such as <code>#pause</code> and <code>#meanwhile</code>,
        allowing you to easily compose dynamic slides, including but not limited to text, lists, and math equations.
      </>
    ),
  },
  {
    title: 'Powered by Typst',
    Svg: require('@site/static/img/undraw_docusaurus_react.svg').default,
    description: (
      <>
        Touying is powered by Typst, which is a new typesetting language with a concise syntax, powerful features, and extremely fast compilation speed.
      </>
    ),
  },
];

function Feature({Svg, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} role="img" />
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
