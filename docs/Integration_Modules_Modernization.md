# Integration Modules Modernization Plan

## Overview

This document outlines the plan to modernize various integration modules from the existing PHP-based system to a modern microservices architecture using TypeScript and Node.js.

## Integration Modules

### 1. BPJS Integration Service
```typescript
// src/services/bpjs/BPJSService.ts
@Injectable()
export class BPJSService {
  constructor(
    private readonly configService: ConfigService,
    private readonly httpService: HttpService
  ) {}

  async verifyMembership(bpjsNumber: string): Promise<BPJSMembershipResponse> {
    const signature = this.generateSignature();
    return this.httpService.get(`/Peserta/${bpjsNumber}`, {
      headers: {
        'X-Signature': signature
      }
    });
  }

  async generateSEP(data: SEPRequest): Promise<SEPResponse> {
    return this.httpService.post('/SEP/create', data);
  }
}
```

### 2. INA-CBG Integration Service
```typescript
// src/services/inacbg/INACBGService.ts
@Injectable()
export class INACBGService {
  async generateClaim(visitData: VisitData): Promise<ClaimResponse> {
    const claim = this.mapVisitToClaim(visitData);
    return this.httpService.post('/claims/generate', claim);
  }

  async getClaimStatus(claimNumber: string): Promise<ClaimStatus> {
    return this.httpService.get(`/claims/${claimNumber}/status`);
  }
}
```

### 3. Laboratory Information System (LIS)
```typescript
// src/services/lis/LISService.ts
@Injectable()
export class LISService {
  async orderTest(testOrder: LabTestOrder): Promise<OrderResponse> {
    return this.httpService.post('/lab/orders', testOrder);
  }

  async getResults(orderId: string): Promise<LabResults> {
    return this.httpService.get(`/lab/results/${orderId}`);
  }

  @MessagePattern('lab.results.ready')
  async handleResultsReady(result: LabResult) {
    // Handle real-time lab results
  }
}
```

### 4. Kemkes Integration Services

#### 4.1 SIRS (Hospital Information System)
```typescript
// src/services/kemkes/SIRSService.ts
@Injectable()
export class SIRSService {
  async submitReport(report: SIRSReport): Promise<SubmissionResponse> {
    const validated = await this.validateReport(report);
    return this.httpService.post('/sirs/reports', validated);
  }

  async getReportStatus(reportId: string): Promise<ReportStatus> {
    return this.httpService.get(`/sirs/reports/${reportId}/status`);
  }
}
```

#### 4.2 RS Online
```typescript
// src/services/kemkes/RSOnlineService.ts
@Injectable()
export class RSOnlineService {
  async updateBedCapacity(data: BedCapacityUpdate): Promise<void> {
    return this.httpService.post('/rsonline/beds', data);
  }

  async reportCovid(data: CovidReport): Promise<void> {
    return this.httpService.post('/rsonline/covid', data);
  }
}
```

### 5. Dukcapil Integration Service
```typescript
// src/services/dukcapil/DukcapilService.ts
@Injectable()
export class DukcapilService {
  async verifyNIK(nik: string): Promise<IdentityVerification> {
    return this.httpService.post('/dukcapil/verify', { nik });
  }

  async getFamilyCard(kkNumber: string): Promise<FamilyCardData> {
    return this.httpService.get(`/dukcapil/kk/${kkNumber}`);
  }
}
```

### 6. Report Integration Service
```typescript
// src/services/report/ReportService.ts
@Injectable()
export class ReportService {
  constructor(
    private readonly bpjsService: BPJSService,
    private readonly inacbgService: INACBGService,
    private readonly lisService: LISService
  ) {}

  async generateIntegratedReport(params: ReportParams): Promise<Report> {
    const [bpjsData, claimData, labData] = await Promise.all([
      this.bpjsService.getReportData(params),
      this.inacbgService.getClaimData(params),
      this.lisService.getLabData(params)
    ]);

    return this.aggregateData(bpjsData, claimData, labData);
  }
}
```

## Shared Infrastructure

### 1. API Gateway
```typescript
// src/gateway/gateway.module.ts
@Module({
  imports: [
    BPJSModule,
    INACBGModule,
    LISModule,
    KemkesModule,
    DukcapilModule,
    ReportModule
  ]
})
export class GatewayModule {}
```

### 2. Message Queue Integration
```typescript
// src/queue/queue.service.ts
@Injectable()
export class QueueService {
  @RabbitSubscribe({
    exchange: 'hospital',
    routingKey: 'lab.results',
    queue: 'lab_results_queue'
  })
  async handleLabResults(result: LabResult) {
    // Process lab results
  }

  @RabbitSubscribe({
    exchange: 'hospital',
    routingKey: 'bpjs.verification',
    queue: 'bpjs_verification_queue'
  })
  async handleBPJSVerification(data: BPJSVerificationData) {
    // Process BPJS verification
  }
}
```

### 3. Shared Authentication
```typescript
// src/auth/auth.service.ts
@Injectable()
export class AuthService {
  async generateServiceToken(service: string): Promise<string> {
    const payload = {
      service,
      timestamp: Date.now()
    };
    return this.jwtService.sign(payload);
  }

  async validateServiceToken(token: string): Promise<boolean> {
    try {
      const decoded = this.jwtService.verify(token);
      return this.validateService(decoded);
    } catch {
      return false;
    }
  }
}
```

## Implementation Steps

1. **Setup Development Environment**
   ```bash
   # Create new NestJS project
   nest new hospital-integration-services
   cd hospital-integration-services
   
   # Install dependencies
   npm install @nestjs/microservices @nestjs/swagger
   npm install @nestjs/jwt @nestjs/config
   npm install amqplib @types/amqplib
   ```

2. **Create Base Services**
   - Implement core service modules
   - Set up shared infrastructure
   - Configure message queues

3. **Implement Integration Services**
   - BPJS integration
   - INA-CBG integration
   - LIS integration
   - Kemkes integrations
   - Dukcapil integration
   - Report service

4. **Testing and Validation**
   - Unit tests
   - Integration tests
   - Load testing
   - Security testing

## Security Considerations

1. **Service Authentication**
   - JWT-based service tokens
   - API key management
   - Rate limiting

2. **Data Protection**
   - End-to-end encryption
   - Data masking
   - Audit logging

3. **Compliance**
   - BPJS security standards
   - Healthcare data regulations
   - Government integration requirements

## Deployment Strategy

1. **Container Orchestration**
   ```yaml
   # docker-compose.yml
   version: '3.8'
   services:
     bpjs-service:
       build: ./services/bpjs
       environment:
         - NODE_ENV=production
         - BPJS_BASE_URL=https://api.bpjs-kesehatan.go.id
     
     inacbg-service:
       build: ./services/inacbg
       environment:
         - NODE_ENV=production
         - INACBG_API_URL=https://api.inacbg.go.id
     
     lis-service:
       build: ./services/lis
       environment:
         - NODE_ENV=production
         - LIS_DATABASE_URL=postgresql://user:pass@db:5432/lis
     
     kemkes-service:
       build: ./services/kemkes
       environment:
         - NODE_ENV=production
         - KEMKES_API_URL=https://api.kemkes.go.id
   ```

2. **CI/CD Pipeline**
   - Automated testing
   - Container builds
   - Deployment automation

3. **Monitoring**
   - Service health checks
   - Performance metrics
   - Error tracking

## Migration Plan

1. **Phase 1: Service Migration**
   - Convert PHP services to TypeScript
   - Implement new API endpoints
   - Setup message queues

2. **Phase 2: Data Migration**
   - Migrate existing data
   - Validate data integrity
   - Setup data synchronization

3. **Phase 3: Deployment**
   - Deploy new services
   - Monitor performance
   - Gradual traffic migration 