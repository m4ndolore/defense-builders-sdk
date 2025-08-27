# Defense Builders SDK - Project Rules & Standards

## Code Organization

### Directory Structure
```
defense-builders-sdk/
├── apps/                       # Application packages
│   ├── web/                   # Next.js marketplace frontend
│   ├── api/                   # Django REST API backend
│   ├── docs/                  # Documentation site
│   └── admin/                 # Admin dashboard
├── packages/                   # Shared packages
│   ├── ui/                    # Shared UI components
│   ├── config/                # Shared configuration
│   ├── types/                 # TypeScript type definitions
│   └── utils/                 # Shared utilities
├── services/                   # Microservices
│   ├── environment-manager/   # Environment provisioning
│   ├── billing/               # Payment processing
│   ├── notifications/         # Email/SMS/Push
│   └── analytics/             # Usage tracking
├── infrastructure/             # Infrastructure as Code
│   ├── terraform/             # Resource provisioning
│   ├── kubernetes/            # K8s manifests
│   └── docker/                # Dockerfiles
├── sdk/                        # SDK packages
│   ├── python/                # Python SDK
│   ├── typescript/            # TypeScript SDK
│   ├── go/                    # Go SDK
│   └── java/                  # Java SDK
├── scripts/                    # Build and deployment scripts
├── tests/                      # End-to-end tests
└── docs/                       # Project documentation
```

### Naming Conventions

#### Files and Directories
```typescript
// React Components
components/UserProfile.tsx      // PascalCase
components/UserProfile.test.tsx // Test files
components/UserProfile.stories.tsx // Storybook

// Utilities and Hooks
utils/formatDate.ts             // camelCase
hooks/useEnvironment.ts         // camelCase with 'use' prefix

// Constants and Config
constants/API_ENDPOINTS.ts      // SCREAMING_SNAKE_CASE
config/database.config.ts       // lowercase with .config suffix

// API Routes
api/users/[id]/route.ts         // kebab-case for URLs
api/environment-manager/route.ts
```

#### Variables and Functions
```typescript
// Variables
const userId = "123";           // camelCase
const MAX_RETRIES = 3;         // SCREAMING_SNAKE_CASE for constants
const isAuthenticated = true;  // boolean with 'is/has/should' prefix

// Functions
function getUserById() {}       // camelCase
function handleSubmit() {}      // verb + noun
async function fetchData() {}   // async prefix with verb

// Classes
class EnvironmentManager {}     // PascalCase
interface UserProfile {}        // PascalCase
type BuilderStatus = "active";  // PascalCase
```

#### Database Conventions
```sql
-- Tables: snake_case plural
CREATE TABLE users ();
CREATE TABLE environment_instances ();

-- Columns: snake_case
user_id, created_at, is_active

-- Indexes: table_column_idx
CREATE INDEX users_email_idx ON users(email);

-- Foreign keys: fk_child_parent
ALTER TABLE projects ADD CONSTRAINT fk_projects_users
```

## Code Standards

### TypeScript/JavaScript

#### Type Safety
```typescript
// Always use strict types
// Bad
function processData(data: any) {}

// Good
function processData(data: UserData) {}

// Use unknown for truly unknown types
function handleError(error: unknown) {
  if (error instanceof Error) {
    console.error(error.message);
  }
}
```

#### Async/Await
```typescript
// Always use async/await over promises
// Bad
function getData() {
  return fetch('/api/data')
    .then(res => res.json())
    .then(data => console.log(data));
}

// Good
async function getData() {
  const response = await fetch('/api/data');
  const data = await response.json();
  console.log(data);
}
```

#### Error Handling
```typescript
// Comprehensive error handling
async function createEnvironment(config: EnvConfig) {
  try {
    const response = await api.post('/environments', config);
    return { success: true, data: response.data };
  } catch (error) {
    logger.error('Environment creation failed', { error, config });
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    };
  }
}
```

### Python

#### Type Hints
```python
# Always use type hints
from typing import Optional, List, Dict

def process_user_data(
    user_id: str,
    filters: Optional[Dict[str, str]] = None
) -> List[Dict[str, any]]:
    """Process user data with optional filters."""
    pass
```

#### Error Handling
```python
# Specific exception handling
try:
    result = perform_operation()
except ValidationError as e:
    logger.error(f"Validation failed: {e}")
    raise
except DatabaseError as e:
    logger.error(f"Database error: {e}")
    return None
except Exception as e:
    logger.exception("Unexpected error")
    raise
```

#### Docstrings
```python
def create_environment(
    user_id: str,
    config: EnvironmentConfig
) -> Environment:
    """
    Create a new development environment.
    
    Args:
        user_id: The ID of the user creating the environment
        config: Configuration for the environment
    
    Returns:
        The created Environment instance
    
    Raises:
        ValidationError: If config is invalid
        QuotaExceededError: If user exceeds resource quota
    """
    pass
```

## Security Standards

### Authentication & Authorization

#### API Security
```typescript
// Always validate JWT tokens
async function authenticateRequest(req: Request) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    throw new UnauthorizedError('No token provided');
  }
  
  try {
    const payload = await verifyJWT(token);
    return payload;
  } catch (error) {
    throw new UnauthorizedError('Invalid token');
  }
}
```

#### Input Validation
```python
# Validate all inputs
from pydantic import BaseModel, validator

class EnvironmentCreate(BaseModel):
    name: str
    sdk_version: str
    resources: Dict[str, int]
    
    @validator('name')
    def validate_name(cls, v):
        if not re.match(r'^[a-z0-9-]+$', v):
            raise ValueError('Name must be lowercase alphanumeric with hyphens')
        return v
    
    @validator('resources')
    def validate_resources(cls, v):
        if v.get('cpu', 0) > 16 or v.get('memory', 0) > 64:
            raise ValueError('Resource limits exceeded')
        return v
```

### Secrets Management

#### Environment Variables
```typescript
// Never hardcode secrets
// Bad
const apiKey = "sk_live_abcd1234";

// Good
const apiKey = process.env.STRIPE_API_KEY;
if (!apiKey) {
  throw new Error('STRIPE_API_KEY not configured');
}
```

#### Secure Storage
```python
# Use secure secret management
from cryptography.fernet import Fernet
import os

def encrypt_sensitive_data(data: str) -> str:
    """Encrypt sensitive data before storage."""
    key = os.environ['ENCRYPTION_KEY']
    cipher = Fernet(key.encode())
    return cipher.encrypt(data.encode()).decode()
```

### Data Protection

#### PII Handling
```typescript
// Mask sensitive data in logs
function logUserActivity(user: User, action: string) {
  logger.info({
    userId: user.id,
    email: maskEmail(user.email), // jo**@example.com
    action,
    timestamp: new Date().toISOString()
  });
}
```

#### SQL Injection Prevention
```python
# Always use parameterized queries
# Bad
query = f"SELECT * FROM users WHERE email = '{email}'"

# Good
query = "SELECT * FROM users WHERE email = %s"
cursor.execute(query, (email,))
```

## Git Workflow

### Branch Naming
```bash
# Feature branches
feature/add-tak-integration
feature/user-dashboard

# Bug fixes
fix/environment-provisioning-timeout
fix/payment-processing-error

# Hotfixes
hotfix/critical-security-patch

# Releases
release/v1.2.0
```

### Commit Messages
```bash
# Format: <type>(<scope>): <subject>

# Types
feat: New feature
fix: Bug fix
docs: Documentation only
style: Formatting, missing semicolons, etc
refactor: Code restructuring
perf: Performance improvements
test: Adding missing tests
chore: Maintenance tasks

# Examples
feat(environment): add GPU support for ML workloads
fix(auth): resolve CAC authentication timeout issue
docs(api): update SDK integration examples
perf(dashboard): optimize project list query
```

### Pull Request Guidelines
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Security Checklist
- [ ] No hardcoded secrets
- [ ] Input validation added
- [ ] SQL injection prevention
- [ ] XSS prevention

## Screenshots (if applicable)
```

## Testing Standards

### Test Coverage Requirements
- **Unit Tests**: Minimum 80% coverage
- **Integration Tests**: All API endpoints
- **E2E Tests**: Critical user flows
- **Security Tests**: Authentication, authorization

### Test Structure
```typescript
// Follow AAA pattern
describe('EnvironmentManager', () => {
  describe('createEnvironment', () => {
    it('should create environment with valid config', async () => {
      // Arrange
      const config = mockEnvironmentConfig();
      const manager = new EnvironmentManager();
      
      // Act
      const result = await manager.createEnvironment(config);
      
      // Assert
      expect(result).toBeDefined();
      expect(result.status).toBe('provisioning');
    });
    
    it('should throw error with invalid config', async () => {
      // Test error cases
    });
  });
});
```

### Test Data
```python
# Use factories for test data
import factory

class UserFactory(factory.Factory):
    class Meta:
        model = User
    
    id = factory.Faker('uuid4')
    email = factory.Faker('email')
    username = factory.Faker('user_name')
    is_active = True
    
# Usage in tests
def test_user_creation():
    user = UserFactory.create()
    assert user.is_active is True
```

## Documentation Standards

### Code Documentation

#### Function Documentation
```typescript
/**
 * Create a new development environment
 * @param config - Environment configuration
 * @param userId - ID of the user creating the environment
 * @returns Promise resolving to the created environment
 * @throws {QuotaExceededError} When user exceeds resource quota
 * @throws {ValidationError} When configuration is invalid
 * @example
 * const env = await createEnvironment({
 *   name: 'dev-env',
 *   sdkVersion: 'latest'
 * }, 'user123');
 */
async function createEnvironment(
  config: EnvironmentConfig,
  userId: string
): Promise<Environment> {
  // Implementation
}
```

### API Documentation
```yaml
# OpenAPI specification
/api/v1/environments:
  post:
    summary: Create new environment
    tags: [Environments]
    security:
      - bearerAuth: []
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/EnvironmentConfig'
    responses:
      201:
        description: Environment created successfully
      400:
        description: Invalid configuration
      401:
        description: Unauthorized
      429:
        description: Rate limit exceeded
```

### README Standards
Each service/package must include:
1. **Overview**: What it does
2. **Installation**: How to set it up
3. **Usage**: Code examples
4. **API Reference**: If applicable
5. **Configuration**: Environment variables
6. **Testing**: How to run tests
7. **Deployment**: Deployment instructions

## Performance Standards

### Frontend Performance
- **LCP**: < 2.5 seconds
- **FID**: < 100 milliseconds
- **CLS**: < 0.1
- **Bundle Size**: < 200KB gzipped (initial)

### Backend Performance
- **API Response**: < 500ms (p95)
- **Database Queries**: < 100ms
- **Background Jobs**: < 5 minutes
- **WebSocket Latency**: < 50ms

### Optimization Requirements
```typescript
// Implement pagination
async function listProjects(page = 1, limit = 25) {
  // Never return unbounded results
}

// Cache expensive operations
const getCachedUserProfile = memoize(getUserProfile, {
  ttl: 60000 // 1 minute
});

// Use database indexes
// Ensure queries use appropriate indexes
```

## Monitoring & Logging

### Logging Standards
```typescript
// Structured logging
logger.info({
  event: 'environment_created',
  userId: user.id,
  environmentId: env.id,
  duration: Date.now() - startTime,
  metadata: {
    sdk: config.sdkVersion,
    resources: config.resources
  }
});
```

### Metrics to Track
- **Business Metrics**: Signups, environments created, SDK usage
- **Performance Metrics**: Response times, error rates, throughput
- **Infrastructure Metrics**: CPU, memory, disk, network
- **Security Metrics**: Failed auth attempts, suspicious activities

### Alerting Rules
- **Critical**: Service down, database unreachable
- **Warning**: High error rate, slow response times
- **Info**: Scheduled maintenance, deployments

## Compliance & Governance

### Data Retention
- **User Data**: 7 years after account closure
- **Transaction Data**: 7 years
- **Logs**: 90 days
- **Backups**: 30 days

### Audit Requirements
- All data access must be logged
- All configuration changes tracked
- Regular security audits (quarterly)
- Compliance reports (annual)

### Privacy Standards
- GDPR compliance for EU users
- CCPA compliance for California users
- Right to deletion implementation
- Data portability features

## Development Environment

### Required Tools
```bash
# Version requirements
node >= 18.0.0
python >= 3.11
docker >= 24.0
kubectl >= 1.28
terraform >= 1.5
```

### IDE Configuration
```json
// VS Code settings.json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "python.linting.enabled": true,
  "python.linting.flake8Enabled": true,
  "python.formatting.provider": "black"
}
```

### Pre-commit Hooks
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
  
  - repo: https://github.com/psf/black
    hooks:
      - id: black
  
  - repo: https://github.com/pycqa/flake8
    hooks:
      - id: flake8
  
  - repo: https://github.com/pre-commit/mirrors-eslint
    hooks:
      - id: eslint
```

## Review Checklist

Before submitting PR, ensure:
- [ ] Code follows style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Security review completed
- [ ] Performance impact assessed
- [ ] Breaking changes documented
- [ ] Changelog updated
- [ ] Version bumped (if needed)